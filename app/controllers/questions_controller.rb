class QuestionsController < ApplicationController
  before_action :authenticate_quiz_user!
  
  def set_question_comment
    data_params = {}
    data_params[:quiz_user_id] = params[:quiz_user_id]
    data_params[:user_type] = 'quiz_user'
    data_params[:id] = params[:id]
    data_params[:quiz_id] = params[:quiz_id]
    data_params[:chat_text] = params[:chat_text]
    res_json = make_request("api/v1/set_question_comment",data_params,"POST")
    if res_json['success']
      @quiz = res_json['quiz']
      @question = res_json['question']
      @chats = @question['comments']
      respond_to do |format|
        format.js { render :show }
      end
    else
      redirect_to :back
    end
  end

  def new
    data_params={}
    res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}",data_params,"GET")
    @quiz = res_json["quiz"]
    @labels = res_json['labels']
    @question = Question.new
    @question.answers.build
  end

  def create
    error_msgs = []
    correct_count = 0
    wrong_count = 0
    no_attachments = true

    if params[:question][:text].blank?
      error_msgs.push("Question cannot be blank.\n")
      flash[:alert] = error_msgs
    end
    
    if params[:question][:study_guide_attachment].present?
      params[:question][:guide_filename] = params[:question][:study_guide_attachment].original_filename
    end

    params[:question][:answers_attributes].each do |(first_index, last_index)|
      if (last_index["text"].blank? && last_index["attachment"].blank?)
        params[:question][:answers_attributes].delete(first_index.to_s)
      else
        if last_index["correct"]=="1"
          correct_count = correct_count + 1
        else
          wrong_count = wrong_count + 1
        end

        if !last_index["attachment"].blank?
          no_attachments = false

          Utils::Utils.add_file_upload_with_keys!(
            params,
            [
              :question,
              :answers_attributes,
              first_index,
              "attachment"
            ]
          )
        end
      end
    end

    if params[:question][:answers_attributes].blank?
      error_msgs.push("You have to enter the answers.\n")
      flash[:alert] = error_msgs
      # redirect_to :back and return
    end

    if correct_count == 0
      error_msgs.push("You have to enter at least one correct answer.\n")
      flash[:alert] = error_msgs
      # redirect_to :back and return
    elsif wrong_count == 0
      error_msgs.push("You have to enter at least one incorrect answer.\n")
      flash[:alert] = error_msgs
      # redirect_to :back and return
    end

    if correct_count == 0 || wrong_count == 0 || params[:question][:answers_attributes].blank? || params[:question][:text].blank?
      data_params = {}
      res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}",data_params,"GET")
      @quiz = res_json["quiz"]
      @labels = res_json["labels"]
      @question = Question.new question_params
      # @question.answers.build
      flash[:alert] = error_msgs
      render :action => 'new' and return

      # redirect_to :back and return
    end

    Utils::Utils.add_file_upload!(params, :study_guide_attachment)
    Utils::Utils.add_file_upload!(params, :attachment)

    no_attachments = (no_attachments &&
                      params[:question][:study_guide_attachment].blank? &&
                      params[:question][:attachment].blank?)

    if no_attachments
      data_params={}
      data_params[:question] = params[:question]
      if params[:label_all].present?
        data_params['label_all[]'] = params[:label_all]
      end
      res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}/questions",data_params,"POST")
      if res_json['success']
        quiz_id = res_json['quiz']['id']
        question_id = res_json['question']['id']
        redirect_to quiz_question_path(quiz_id,question_id) and return
      else
        redirect_to :back
      end
    else
      @response = Utils::Utils.make_post_request_with_upload!(
        "api/v1/quizzes/#{params[:quiz_id]}/questions",
        {
          "question" => params[:question],
          "auth_token" => session[:auth_token],
          'label_all[]' => params[:label_all]
        }
      )

      if @response.code.to_i == 200
        res_json = JSON.parse(@response.body)
        quiz_id = res_json['quiz']['id']
        question_id = res_json['question']['id']
        redirect_to quiz_question_path(quiz_id,question_id) and return
      else
        b = @response.body
        flash[:alert] = "An Error Occured while adding question."
        return redirect_to :back
      end
    end
  end

  def show
    data_params={}
    res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}/questions/#{params[:id]}",data_params,"GET")
    if res_json['success']
      @quiz = res_json['quiz']
      @question = res_json['question']
      @qs = res_json['questions']
      @current_page = @question['question_number']
      @total_questions =  @qs.last['question_number']

      current_index = @qs.index {|h| h["question_number"] == @current_page }

      prev_index = 0
      prev_index = current_index -1 unless current_index == 0
      next_index = current_index + 1 
      prev_list = @qs[prev_index]

      next_list = @qs[next_index]

      if next_list.present?
        @next_url = "/quizzes/#{@quiz['id']}/questions/#{next_list['id']}"
      else
        @next_url = "javascript:void(0);"
      end

      if prev_list.present?
        @prev_url = "/quizzes/#{@quiz['id']}/questions/#{prev_list['id']}"
      else
        @prev_url = "javascript:void(0);"
      end
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end

  end

  def change_order
    @question.change_order params[:move].to_i
    redirect_to [@device, @quiz]
  end

  def edit
    data_params={}
    res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}/questions/#{params[:id]}/edit",data_params,"GET")

    if res_json['success']
      @quiz = res_json['quiz']
      @question = res_json['question']
      @question_labels = res_json["question_labels"]
      @labels = res_json["labels"]
      question = Question.find_by_id @question['id']
      params[:question] =  set_params_question(@question)

      if question.present?
        params[:question] = params[:question].except(:answers_attributes)
        question.update question_params
        question.answers.destroy_all
      else
        question = Question.create question_params
      end

      @question['answers'].each do |answer|
        question.answers.create(
          id: answer['id'],
          text: answer['text'],
          question_id: answer['question_id'],
          latex: answer['latex'],
          correct: answer['correct'],
          created_at: answer['created_at'],
          updated_at: answer['updated_at'],
          attachment_url: answer['attachment']['url']
        )
      end
      @question = question
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end

  end

  def update
    require 'mime/types'
    require 'rack'

    correct_count = 0
    wrong_count = 0
    empty_count = 0

    no_attachments = true

    if params[:question][:study_guide_attachment].present?
      params[:question][:guide_filename] = params[:question][:study_guide_attachment].original_filename
    end

    params[:question][:answers_attributes].each do |t|
      first_index = t.first
      last_index = t.last
      if (last_index["_destroy"] !="false" &&
          last_index["text"].blank? &&
          last_index["attachment"].blank?)
        params[:question][:answers_attributes].delete(first_index.to_s)
      else
        if last_index["_destroy"] == "false"
          empty_count = empty_count + 1
          if last_index["correct"]=="1" 
            correct_count = correct_count + 1
          else
            wrong_count = wrong_count + 1
          end

          if !last_index["attachment"].blank?
            no_attachments = false

            Utils::Utils.add_file_upload_with_keys!(
              params,
              [
                :question,
                :answers_attributes,
                first_index,
                "attachment"
              ]
            )
          end
        end
      end
    end

    if params[:question][:answers_attributes].blank? || empty_count == 0
      flash[:alert] = "You have to enter the answers"
      redirect_to :back and return
    end

    if correct_count == 0
      flash[:alert] = "You have to enter at least one correct answer"
      redirect_to :back and return
    elsif wrong_count == 0
      flash[:alert] = "You have to enter at least one incorrect answer"
      redirect_to :back and return
    end

    Utils::Utils.add_file_upload!(params, :study_guide_attachment)
    Utils::Utils.add_file_upload!(params, :attachment)

    no_attachments = (no_attachments &&
                      params[:question][:study_guide_attachment].blank? &&
                      params[:question][:attachment].blank?)
    if no_attachments
      data_params={}
      data_params[:question] = params[:question]
      if params[:label_all].present?
        data_params['label_all[]'] = params[:label_all]
      end
      res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}/questions/#{params[:id]}",data_params,"PUT")
      if res_json['success']
        quiz_id = res_json['quiz']['id']
        question_id = res_json['question']['id']
        redirect_to quiz_question_path(quiz_id,question_id)
        return
      else
        redirect_to :back
      end
    else
      @response = Utils::Utils.make_put_request_with_upload!(
        "api/v1/quizzes/#{params[:quiz_id]}/questions/#{params[:id]}",
        {
          "question" => params[:question],
          "auth_token" => session[:auth_token]
        }
      )

      if @response.code.to_i == 200
        res_json = JSON.parse(@response.body)
        quiz_id = res_json['quiz']['id']
        question_id = res_json['question']['id']
        redirect_to quiz_question_path(quiz_id,question_id) and return
      else
        flash[:alert] = "An Error Occured while adding question."
        return redirect_to :back
      end
    end
  end

  def destroy
    data_params ={}
    res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}/questions/#{params[:id]}",data_params,"DELETE")
    if res_json['success']
      flash[:success] = "Question deleted successfully"
      @quiz = res_json['quiz']
      redirect_to quiz_path(@quiz['id'])
    else
      @quiz = res_json['quiz']
      flash[:error] = "Could not delete question for some reason, Try again later."
      redirect_to quiz_path(@quiz['id'])
    end
  end

  private

    def question_params
      params.require(:question).permit(
        :id,
        :quiz_id,
        :latex,
        :attachment_url,
        :text,
        :hint,
        :comment,
        :study_guide,
        :study_guide_attachment_url,
        :question_guide_pdf_preview_url,
        :guide_filename,
        :priority,
        :created_at,
        :updated_at,
        answers_attributes: [
          :id, :latex, :text,
          :question_id, :correct,
          :created_at, :updated_at,
          :_destroy, :attachment_url
        ]
      )
    end

    def set_params_question(question)
      data_params={}
      data_params[:question] = {}
      data_params[:question][:id] = question['id']
      data_params[:question][:latex] = question['latex']
      data_params[:question][:attachment_url] = question['attachment_url']
      data_params[:question][:text] = question['text']
      data_params[:question][:quiz_id] = question['quiz_id']
      data_params[:question][:created_at] = question['created_at']
      data_params[:question][:updated_at] = question['updated_at']
      data_params[:question][:hint] = question['hint']
      data_params[:question][:comment] = question['comment']
      data_params[:question][:study_guide] = question['study_guide']
      data_params[:question][:study_guide_attachment_url] = question['study_guide_attachment_url']
      data_params[:question][:question_guide_pdf_preview_url] = question['question_guide_pdf_preview_url']
      data_params[:question][:guide_filename] = question['guide_filename']
      data_params[:question]
    end

    def load_device_and_quiz
      # @device = current_user.devices.find params[:device_id]
      # @quiz = @device.quizzes.find params[:quiz_id]
      @quiz = Quiz.find_by_id params[:quiz_id]
    end

    def load_question
      @question = @quiz.questions.find params[:id]
    end

    def load_quiz_selection
      # @quiz_selection = @device.quiz_selections.find_by quiz_id: params[:quiz_id]
    end

    def mime_for_file(f)
      m = MIME::Types.type_for(f.path.split('.').last)
      m.empty? ? "application/octet-stream" : m.to_s
    end
end
