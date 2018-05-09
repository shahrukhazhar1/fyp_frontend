class CoursesController < ApplicationController
  before_action :authenticate_quiz_user!
  
  def index
    data_params = {}
    res_json = make_request("api/v1/courses",data_params,"GET")
    if res_json['success']
      @courses = res_json['courses']
    else
      flash[:alert] = "An error occured while displaying courses"
      redirect_to :back
    end
  end
  
  def new
    data_params={}
    res_json = make_request("api/v1/courses/fetch_labels",data_params,"GET")
    @labels = res_json['labels']
  end

  def create
    require 'mime/types'
    require 'rack'

    unless params[:course][:attachment].blank?
      upload = params[:course][:attachment].is_a?(String)
      filename = upload  ? params[:course][:attachment] : params[:course][:attachment].original_filename
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
          f.write params[:course][:attachment].read
        end
      end
      file = File.open(tmp_file)
      params[:course][:attachment] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    unless params[:course][:attachment2].blank?
      upload = params[:course][:attachment2].is_a?(String)
      filename = upload  ? params[:course][:attachment2] : params[:course][:attachment2].original_filename
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
          f.write params[:course][:attachment2].read
        end
      end
      file = File.open(tmp_file)
      params[:course][:attachment2] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    error_msgs = []
    data_params={}
    data_params[:course] = params[:course]
    if params[:label_all].present?
      data_params['label_all[]'] = params[:label_all]
    end

    if params[:course][:attachment].blank? && params[:course][:attachment2].blank?
      res_json = make_request("api/v1/courses",data_params,"POST")
    else
      @response = Utils::Utils.make_post_request_with_upload!(
        "api/v1/courses",
        {
          "course" => params[:course],
          "auth_token" => session[:auth_token],
          'label_all[]' => params[:label_all]
        }
      )
      # if Rails.env.production?
      #   url = "#{Rails.configuration.parent_portal_url}/" + 'api/v1/courses'
      #   uri = URI(url)

      #   res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      #     request = Net::HTTP::Post.new(uri.request_uri)

      #     request.body = Rack::Multipart::Generator.new(
      #       "course"                  => params[:course],
      #       "auth_token"             => session[:auth_token],
      #       'label_all[]' => params[:label_all]
      #     ).dump
      #     request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
      #     @response = http.request(request)
      #   end


      # else
      #   url = "http://localhost:5000/" + 'api/v1/courses'
      #   uri = URI(url)
      #   http    = Net::HTTP.new(uri.host, uri.port)
      #   request = Net::HTTP::Post.new(uri.request_uri)
      #   request.body = Rack::Multipart::Generator.new(
      #     "course"                  => params[:course],
      #     "auth_token"             => session[:auth_token]
      #     # ,'label_all[]' => params[:label_all]

      #   ).dump
      #   request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
      #   @response = http.request(request)

      # end
      if @response.code.to_i == 200
        res_json = JSON.parse(@response.body)
      else
        res_json ||={}
        res_json['success'] = false
      end
    end

    if res_json['success']
      course_id = res_json['course']['id']
      redirect_to course_path(course_id) and return
    else
      flash[:alert] = "An error occured while adding course"
      redirect_to :back
    end
  end

  def show
    data_params={}
    res_json = make_request("api/v1/courses/#{params[:id]}",data_params,"GET")
    if res_json['success']
      @course = res_json['course']
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end

  end

  def edit
    data_params={}
    res_json = make_request("api/v1/courses/#{params[:id]}/edit",data_params,"GET")

    if res_json['success']
      @course = res_json['course']
      @course_labels = res_json["course_labels"]
      @labels = res_json["labels"]

      
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end
  end

  def update

    require 'mime/types'
    require 'rack'
    
    unless params[:course][:attachment].blank?
      upload = params[:course][:attachment].is_a?(String)
      filename = upload  ? params[:course][:attachment] : params[:course][:attachment].original_filename
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
          f.write params[:course][:attachment].read
        end
      end
      file = File.open(tmp_file)
      params[:course][:attachment] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end

    unless params[:course][:attachment2].blank?
      upload = params[:course][:attachment2].is_a?(String)
      filename = upload  ? params[:course][:attachment2] : params[:course][:attachment2].original_filename
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
          f.write params[:course][:attachment2].read
        end
      end
      file = File.open(tmp_file)
      params[:course][:attachment2] = Rack::Multipart::UploadedFile.new(file.path, mime_for_file(file))
      File.delete(file.path)
    end


    data_params = {}
    data_params[:course] = params[:course]
    if params[:label_all].present?
      data_params['label_all[]'] = params[:label_all]
    end
    if params[:course][:attachment].blank? && params[:course][:attachment2].blank?
      res_json = make_request("api/v1/courses/#{params[:id]}",data_params,"PUT")
    else
      if Rails.env.production?
        url = "#{Rails.configuration.parent_portal_url}/" + "api/v1/courses/#{params[:id]}"
        uri = URI(url)

        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Put.new(uri.request_uri)

          request.body = Rack::Multipart::Generator.new(
            "course_id"  => params[:id],
            "course"                  => params[:course],
            "auth_token"             => session[:auth_token]
          ).dump
          request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
          @response = http.request(request)
        end
  
      else
        url = "http://localhost:5000/" + "api/v1/courses/#{params[:id]}"
        uri = URI(url)

        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Put.new(uri.request_uri)
        request.body = Rack::Multipart::Generator.new(
          "course_id"  => params[:id],
          "course"                  => params[:course],
          "auth_token"             => session[:auth_token]
        ).dump
        request.content_type = "multipart/form-data, boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
        @response = http.request(request)

        if @response.code.to_i == 200
          res_json = JSON.parse(@response.body)
        else
          res_json ||={}
          res_json['success'] = false
        end
      end
    end
    if res_json['success']
      course_id = res_json['course']['id']
      flash[:success] = "Course updated successfully"
      redirect_to course_path(course_id)
      return
    else
      redirect_to :back
    end
  end
  

  def destroy
    data_params ={}
    res_json = make_request("api/v1/courses/#{params[:id]}",data_params,"DELETE")
    if res_json['success']
      flash[:success] = "Course deleted successfully"
    else
      flash[:error] = "Could not delete course for some reason, Try again later."
    end
    redirect_to courses_path
  end

  private

    def course_params
      params.require(:course).permit(:id,:name)
    end

    def mime_for_file(f)
      m = MIME::Types.type_for(f.path.split('.').last)
      m.empty? ? "application/octet-stream" : m.to_s
    end
end
