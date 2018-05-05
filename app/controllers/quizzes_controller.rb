class QuizzesController < ApplicationController

  before_action :authenticate_quiz_user!, :except => [:update_row_order]

  def quiz_results
    
    data_params={}
    res_json = make_request("/api/v1/quizzes/quiz_results",data_params,"GET")
    if res_json['success']
      @quiz_results = res_json["quiz_results"]
    else
      flash[:alert] = "An error occured. Can't display quiz results"
      redirect_to root_path
    end
  end

  def set_comment
    data_params = {}
    data_params[:quiz_user_id] = params[:quiz_user_id]
    data_params[:user_type] = 'quiz_user'
    data_params[:id] = params[:id]
    data_params[:chat_text] = params[:chat_text]
    res_json = make_request("api/v1/set_comment",data_params,"POST")
    if res_json['success']
      @quiz = res_json['quiz']
      @chats = @quiz['comments']
      respond_to do |format|
        format.js { render :show }
      end
    else
      redirect_to :back
    end
  end

  def new_verison
    data_params = {}
    res_json = make_request("api/v1/quizzes/#{params[:id]}/new_verison",data_params,"GET")
    if res_json['success']
      @quiz_revise = res_json['quiz_revise']
      redirect_to edit_quiz_path(@quiz_revise['id'])
    else
      redirect_to :back
    end 
  end

  def edit
    data_params={}
    res_json = make_request("api/v1/quizzes/#{params[:id]}/edit",data_params,"GET")
    
    if res_json['success']
      @quiz = res_json["quiz"]
      @grades = res_json["grades"]
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end
  end

  def study_guide
    if params[:study_text] || params[:study_comment].present?
      data_params = {}
      data_params[:study_text] = params[:study_text]
      data_params[:study_comment] = params[:study_comment]
      res_json = make_request("api/v1/quizzes/#{params[:id]}/study_guide",data_params,"GET")
      if res_json['success']
        @quiz = res_json['quiz']
        flash[:notice]="Study Guide Save"
        redirect_to quiz_path(@quiz['id'])
      else
        redirect_to :back
      end
    else
      data_params={}
      res_json = make_request("api/v1/quizzes/#{params[:id]}",data_params,"GET")
      @quiz = res_json["quiz"]
      @grades = res_json["grades"]
    end
  end

  def submit_for_approval
    data_params = {}
    res_json = make_request("api/v1/quizzes/#{params[:id]}/submit_for_approval",data_params,"GET")
    if res_json['success']
      flash[:notice]="Quiz submitted for Admin Approval"
      @quiz = res_json['quiz']
      redirect_to quiz_path(@quiz['id'])
    else
      flash[:notice]="An Error Occured"
      redirect_to :back
    end
  end


  def index
    # @q = @device.quiz_selections.ransack(params[:q])
    # @quizzes = @q.result(distinct: true).includes(:quiz => :grade).joins(:quiz => :grade)
    @q = Quiz.all.ransack(params[:q])
    # @quizzes = @q.result(distinct: true).includes(:grade).joins(:grade)
    @quizzes = @q.result(distinct: true)
  end

  def all_quizzes
    @quizzes = QuizSelection.joins(:device).where('devices.user_id = ?', current_user.id)
      .includes(:device, :quiz => :grade).order('quiz_selections.created_at DESC')
  end

  def new
    data_params = {}
    res_json = make_request("api/v1/quizzes/get_grades",data_params,"GET")
    @quiz_new = res_json['grades']
    @courses = res_json['courses']

  end

  def create
    require 'mime/types'
    require 'rack'

    unless params[:quiz][:attachment].blank?
      upload = params[:quiz][:attachment].is_a?(String)
      filename = upload  ? params[:quiz][:attachment] : params[:quiz][:attachment].original_filename
      params[:quiz][:quiz_supplement_filename] = filename
      extension = filename.split('.').last
      tmp_file = "#{Rails.root}/tmp/uploaded.#{extension}"
      id = 0
      while File.exists?(tmp_file) do
        tmp_file = "#{Rails.root}/tmp/uploaded-#{id}.#{extension}"        
        id += 1
      end
      File.open(tmp_file, 'wb') do |f|
        if upload
          f.write  request.body.read
        else
          f.write params[:quiz][:attachment].read
        end
      end
      file = File.open(tmp_file)
      params[:quiz][:attachment] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    unless params[:quiz][:quiz_guide_attachment].blank?
      upload = params[:quiz][:quiz_guide_attachment].is_a?(String)
      filename = upload  ? params[:quiz][:quiz_guide_attachment] : params[:quiz][:quiz_guide_attachment].original_filename
      params[:quiz][:quiz_guide_attachment_filename] = filename
      extension = filename.split('.').last
      tmp_file = "#{Rails.root}/tmp/uploaded.#{extension}"
      id = 0
      while File.exists?(tmp_file) do
        tmp_file = "#{Rails.root}/tmp/uploaded-#{id}.#{extension}"
        id += 1
      end
      File.open(tmp_file, 'wb') do |f|
        if upload
          f.write  request.body.read
        else
          f.write params[:quiz][:quiz_guide_attachment].read
        end
      end
      file = File.open(tmp_file)
      params[:quiz][:quiz_guide_attachment] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    if params[:quiz][:attachment].blank? && params[:quiz][:quiz_guide_attachment].blank?

      data_params={}
      data_params[:quiz] = params[:quiz]

      if params[:grade_all].present?
        data_params['grade_all[]'] = params[:grade_all]
      end
      res_json = make_request('api/v1/quizzes',data_params,request.env["REQUEST_METHOD"])
      @quiz =  res_json['quiz']

    else
      tmp_grade_params = params[:grade_all]
      if Rails.env.production?
        url = "#{Rails.configuration.parent_portal_url}/" + 'api/v1/quizzes'
        uri = URI(url)

        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Post.new(uri.request_uri)

          request.body = Rack::Multipart::Generator.new(
            "quiz"                  => params[:quiz],
            "auth_token"             => session[:auth_token]
          ).dump
          request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
          @response = http.request(request)
        end


      else
        url = "http://localhost:5000/" + 'api/v1/quizzes'
        uri = URI(url)
        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = Rack::Multipart::Generator.new(
          "quiz"                  => params[:quiz],
          "auth_token"             => session[:auth_token]
        ).dump
        request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
        @response = http.request(request)

      end

      if @response.code.to_i == 200
        res_json = JSON.parse(@response.body)
        @quiz = res_json['quiz']
        data_params = {}
        data_params[:quiz_id] = @quiz['id']
        data_params['grade_all[]'] = tmp_grade_params
        res_json = make_request("api/v1/quizzes/add_grades",data_params,"POST")
      else
        flash[:alert] = "An Error Occured while adding quiz."
        return redirect_to :back
      end
    end

    if @quiz.present?
      redirect_to new_quiz_question_path(@quiz['id'])
    else
      redirect_to new_quiz_path
    end
  end

  def update

    ###############################################
    require 'mime/types'
    require 'rack'
    
    unless params[:quiz][:attachment].blank?
      upload = params[:quiz][:attachment].is_a?(String)
      filename = upload  ? params[:quiz][:attachment] : params[:quiz][:attachment].original_filename
      params[:quiz][:quiz_supplement_filename] = filename
      extension = filename.split('.').last
      tmp_file = "#{Rails.root}/tmp/uploaded.#{extension}"
      id = 0
      while File.exists?(tmp_file) do
        tmp_file = "#{Rails.root}/tmp/uploaded-#{id}.#{extension}"        
        id += 1
      end
      File.open(tmp_file, 'wb') do |f|
        if upload
          f.write  request.body.read
        else
          f.write params[:quiz][:attachment].read
        end
      end
      file = File.open(tmp_file)
      params[:quiz][:attachment] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    unless params[:quiz][:quiz_guide_attachment].blank?
      upload = params[:quiz][:quiz_guide_attachment].is_a?(String)
      filename = upload  ? params[:quiz][:quiz_guide_attachment] : params[:quiz][:quiz_guide_attachment].original_filename
      extension = filename.split('.').last
      params[:quiz][:quiz_guide_attachment_filename] = filename
      tmp_file = "#{Rails.root}/tmp/uploaded.#{extension}"
      id = 0
      while File.exists?(tmp_file) do
        tmp_file = "#{Rails.root}/tmp/uploaded-#{id}.#{extension}"        
        id += 1
      end
      File.open(tmp_file, 'wb') do |f|
        if upload
          f.write  request.body.read
        else
          f.write params[:quiz][:quiz_guide_attachment].read
        end
      end
      file = File.open(tmp_file)
      params[:quiz][:quiz_guide_attachment] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    if params[:quiz][:attachment].blank? && params[:quiz][:quiz_guide_attachment].blank?

      data_params = {}
      data_params[:quiz] = params[:quiz]
      if params[:grade_all].present?
        data_params['grade_all[]'] = params[:grade_all]
      end
      res_json = make_request("api/v1/quizzes/#{params[:id]}",data_params,"PUT")
      if res_json['success']
        flash[:success] = "Quiz updated successfully."
        @quiz =  res_json['quiz']
      end

    else
      tmp_grade_params = params[:grade_all]
      if Rails.env.production?
        url = "#{Rails.configuration.parent_portal_url}/" + "api/v1/quizzes/#{params[:id]}"
        uri = URI(url)

        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Put.new(uri.request_uri)

          request.body = Rack::Multipart::Generator.new(
            "quiz_id"  => params[:id],
            "quiz"                  => params[:quiz],
            "auth_token"             => session[:auth_token]
          ).dump
          request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
          @response = http.request(request)
        end
  
      else
        url = "http://localhost:5000/" + "api/v1/quizzes/#{params[:id]}"
        uri = URI(url)

        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Put.new(uri.request_uri)
        request.body = Rack::Multipart::Generator.new(
          "quiz_id"  => params[:id],
          "quiz"                  => params[:quiz],
          "auth_token"             => session[:auth_token]
        ).dump
        request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
        @response = http.request(request)

      end
      
      if @response.code.to_i == 200
        res_json = JSON.parse(@response.body)
        @quiz = res_json['quiz']
        data_params = {}
        data_params[:quiz_id] = @quiz['id']
        data_params['grade_all[]'] = tmp_grade_params
        res_json = make_request("api/v1/quizzes/update_grades",data_params,"POST")
      else
        flash[:alert] = "An Error Occured while updating quiz."
        return redirect_to :back
      end
    end
    
    ####################################################

    flash[:success] = "Quiz updated successfully."
    redirect_to quiz_path(@quiz['id'])


  end

  def show
    data_params={}
    res_json = make_request("api/v1/quizzes/#{params[:id]}",data_params,"GET")
    if res_json['success']
      @quiz = res_json["quiz"]
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end
  end

  # def update_row_order
  #   @device = current_user.devices.find params[:id]
  #   @thing = Quiz.find(params[:thing][:thing_id])
  #   @thing.row_order_position = params[:thing][:row_order_position]
  #   @thing.save
  #   @quizzes = @device.quizzes.quiz_queue_search(whitelist_search_params).rank(:row_order).page(params[:page]).per(5)
  #   respond_to do |format|
  #     format.js { render :quiz_queue }
  #   end

  #   # render nothing: true
  # end

  def approve
    if @quiz.present?
      @quiz.quiz_status = 'approved'
      @quiz.approval_date = DateTime.now
      @quiz.approved_by = current_quiz_admin.email
      @quiz.save!
      flash[:notice]="Quiz Approved"
    end
    redirect_to :back
  end

  def reject
    if @quiz.present?
      @quiz.quiz_status = 'rejected'
      @quiz.save!
      flash[:notice]="Quiz Rejected"
    end
    redirect_to :back
  end

  private

    def quiz_params
      params.require(:quiz).permit :name, :subject, :grade_id, :passing_percentage, :topic, :description, :test_prep
    end

    def load_device
      @device = current_user.devices.find params[:device_id]
    end

    def load_quiz
      # @quiz = @device.quizzes.find params[:id]
      @quiz = Quiz.find params[:id]
    end

    def load_quiz_selection
      @quiz_selection = @device.quiz_selections.find_by quiz_id: params[:id]
    end

    def mime_for_file(f)
      m = MIME::Types.type_for(f.path.split('.').last)
      m.empty? ? "application/octet-stream" : m.to_s
    end

end
