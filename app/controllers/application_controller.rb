class ApplicationController < ActionController::Base
	require 'uri'
  require 'net/http'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  def authenticate_quiz_user!
    if session[:auth_token].blank?
      flash[:alert] = 'First Login to continue'
      return redirect_to "/quiz_users/sign_in"
    end
  end

  def make_request(url, data_params, request)
    # url = APP_CONFIG["domain"] + url
    if Rails.env.production?
      url = "#{Rails.configuration.parent_portal_url}/" + url
    else
      url = "http://localhost:5000/" + url
    end
    uri = URI(url)
    data_params["_method"] = "DELETE" if request=='DELETE'
    data_params["_method"] = "PUT" if request=='PUT'
    # data_params["_method"] = "PATCH" if request=='PATCH'
    data_params[:auth_token]= session[:auth_token] unless session[:auth_token].blank?
    if ['POST', 'PUT', 'DELETE'].include?(request)
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        req = Net::HTTP::Post.new(uri.path)
        req.set_form_data(data_params)
        http.read_timeout = 700
        @response = http.request(req)
      end
    end
    if request == 'GET'
      res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        uri.query = data_params.to_query
        req = Net::HTTP::Get.new(uri.to_s)
        @response = HTTParty.get(uri.to_s)
        # @response = http.request(req)
      end
    end

    # return flash[:alert] = "Unauthorized!" if @response.code.to_i==401
    return res_json = JSON.parse(res.body) if @response.code.to_i!=500

    logger.error "failed api response"
    logger.error @response

    return ''
  end
end
