class QuizUsers::RegistrationsController < Devise::RegistrationsController

  def create
  	# super
    data_params={}
    data_params[:quiz_user]=params[:quiz_user]
    res_json = make_request('api/v1/register',data_params,request.env["REQUEST_METHOD"])
    if @response.code.to_i==200
      flash[:success] = 'Account created successfully'
      redirect_to quiz_user_session_path
    else
      flash.now[:alert] = res_json["error"].join(' , ')
      # @data = res_json["data"]
      redirect_to quiz_user_session_path
    end
  end

  def update
  	super
  end

  protected
    def after_update_path_for(resource)
    	flash[:notice]="Password changed successfuly"
    	quiz_creation_index_path
    end

  def after_inactive_sign_up_path_for(resource)
    flash[:notice]="Quiz User created successfuly"
    new_quiz_user_session_path
  end

end