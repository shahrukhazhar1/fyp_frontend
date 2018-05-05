class QuizUsers::ConfirmationsController < DeviseController
  # protected
  # def after_confirmation_path_for(resource_name, resource)
  #   profile_after_confirm_path
  # end

  def new
    super
  end

  def create
    super
  end

  def show
    data_params={}
    data_params[:confirmation_token] = params[:confirmation_token]
    res_json = make_request('api/v1/confirmation',data_params,"GET")
    if @response.code.to_i==200
      redirect_to quiz_user_session_path
    else
      flash.now[:alert] = res_json
      redirect_to quiz_user_session_path
    end
  end


end