class QuizUsers::SessionsController < Devise::SessionsController
  before_filter :authenticate_quiz_user!, :only => [:destroy]
  before_filter :check_login, only: [:create, :new]
  skip_before_action :verify_signed_out_user, :only => [:destroy]
  def new
    super
  end

  def create
    # super
    data_params={}
    data_params[:quiz_user]=params[:quiz_user]
    res_json = make_request('api/v1/login',data_params,request.env["REQUEST_METHOD"])
    if @response.code.to_i==200
      session[:auth_token] = res_json["auth_token"]
      session[:quiz_user] = res_json["quiz_user"]
      # redirect_to session[:previous_url] || root_path
      redirect_to quiz_creation_index_path
    else
      flash[:alert] = res_json['message']
      redirect_to quiz_user_session_path
    end
  end
  
  def destroy
    data_params={}
    data_params[:auth_token] = session[:auth_token]

    res_json = make_request('api/v1/logout',data_params,request.env["REQUEST_METHOD"])
    session[:auth_token] = nil
    session[:quiz_user] = nil
    flash[:success] = 'You have Logged out'
    return redirect_to quiz_user_session_path
    # if @response.code.to_i==200
    #   session[:auth_token] = nil
    #   session[:quiz_user] = nil
    #   flash[:success] = 'You have Logged out'
    #   return redirect_to quiz_users_session_path
    # else
    #   flash.now[:error] = 'Unauthorized!'
    #   return redirect_to :back
    # end
  end

  private

  def check_login
    if session[:quiz_user].present?
      redirect_to quiz_creation_index_path
    end
  end

end