class QuizCreationController < ApplicationController
	before_action :authenticate_quiz_user!, except: [:check_email]

  def messages
    data_params = {}
    
    if params[:quiz_id].present? && params[:question_id].present?
      res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}/questions/#{params[:question_id]}",data_params,"GET")
      @quiz = res_json['quiz']
      @question = res_json['question']
      @questions = res_json['questions']
    

    elsif params[:quiz_id].present?
      res_json = make_request("api/v1/quizzes/#{params[:quiz_id]}",data_params,"GET")
      if res_json['success']
        @quiz = res_json["quiz"]
        @grades = res_json["grades"]
        @questions = res_json["questions"]
        @question = @questions.first if @questions.present?
      else
        @quiz = nil
        @grades = nil
        @questions = nil
        @question = nil
      end
    else
      res_json = make_request("api/v1/quiz_messages",data_params,"GET")
      @quiz_results = res_json["quizzes"]
      @quiz_results ||=[]  
    end

    respond_to do |format|
      format.html do
      end
      format.js { render :msg_queue }
    end
    
  end
  
  def switch_alerts
    data_params = {}
    data_params[:switch_val] = params[:switch_val]
    res_json = make_request("api/v1/set_switch_val",data_params,"POST")
    return render json: true
  end

  def set_sample_question
    data_params = {}
    data_params[:question_id] = params[:question_id]
    res_json = make_request("api/v1/set_sample_question",data_params,"POST")
    return render json: true
  end


  def check_email
    data_params = {}
    data_params[:quiz_user] = params[:quiz_user]
    res_json = make_request('check_quiz_user_email',data_params,"POST")
    result = res_json["success"]
    return render :json => result
  end  
  
  def index
    data_params={}
    res_json = make_request('api/v1/quiz_creation',data_params,"GET")
    @quiz_results = res_json["quizzes"]
    @quiz_results ||=[]
  end

  def new
  end

  def edit
  end

  def update
  end
  
  def rejected_quizzes
    data_params={}
    res_json = make_request('api/v1/quiz_creation/rejected_quizzes',data_params,"GET")
    @quiz_results = res_json["rejected_quizzes"]
  end

  def approved_quizzes
    data_params={}
    data_params[:q]=params[:q]
    res_json = make_request('api/v1/quiz_creation/approved_quizzes',data_params,"GET")
    @grades = res_json["grades"]
    @quiz_results = res_json["approved_quizzes"]
  end

  def unfinished_quizzes
    data_params={}
    res_json = make_request('api/v1/quiz_creation/unfinished_quizzes',data_params,"GET")
    @quiz_results = res_json["unfinished_quizzes"]
  end

  def submitted_quizzes
    data_params={}
    res_json = make_request('api/v1/quiz_creation/submitted_quizzes',data_params,"GET")
    @quiz_results = res_json["submitted_quizzes"]
  end

  def tutorials
  end

  def quiz_user_account
    data_params = {}
    res_json = make_request('api/v1/user_info',data_params,"GET")
    @quiz_user = res_json["quiz_user"]
  end

  def settings
    data_params={}
    data_params[:quiz_user] = params[:quiz_user]
    res_json = make_request('api/v1/users/update_password',data_params,"POST")
    if res_json["success"]
      flash[:notice] = 'Password changed successfully'
      redirect_to quiz_creation_index_path
    else
      flash[:notice] = res_json['message']
      redirect_to :back
    end
  end

end
