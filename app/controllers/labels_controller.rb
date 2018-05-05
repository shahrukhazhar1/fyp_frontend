class LabelsController < ApplicationController
  before_action :authenticate_quiz_user!
  
  def index
    data_params = {}
    res_json = make_request("api/v1/labels",data_params,"GET")
    if res_json['success']
      @labels = res_json['labels']
    else
      flash[:alert] = "An error occured while displaying labels"
      redirect_to :back
    end
  end
  
  def new
  end

  def create
    error_msgs = []
    data_params={}
    data_params[:label] = params[:label]
    res_json = make_request("api/v1/labels",data_params,"POST")
    if res_json['success']
      label_id = res_json['label']['id']
      redirect_to label_path(label_id) and return
    else
      flash[:alert] = "An error occured while adding label"
      redirect_to :back
    end
  end

  def show
    data_params={}
    res_json = make_request("api/v1/labels/#{params[:id]}",data_params,"GET")
    if res_json['success']
      @label = res_json['label']
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end

  end

  def edit
    data_params={}
    res_json = make_request("api/v1/labels/#{params[:id]}/edit",data_params,"GET")

    if res_json['success']
      @label = res_json['label']
    else
      flash[:alert] = res_json["message"]
      redirect_to root_path
    end
  end

  def update
    data_params = {}
    data_params[:label] = params[:label]
    res_json = make_request("api/v1/labels/#{params[:id]}",data_params,"PUT")
    if res_json['success']
      label_id = res_json['label']['id']
      flash[:success] = "label updated successfully"
      redirect_to label_path(label_id)
      return
    else
      redirect_to :back
    end
  end
  

  def destroy
    data_params ={}
    res_json = make_request("api/v1/labels/#{params[:id]}",data_params,"DELETE")
    if res_json['success']
      flash[:success] = "label deleted successfully"
    else
      flash[:error] = "Could not delete label for some reason, Try again later."
    end
    redirect_to labels_path
  end

  private

    def label_params
      params.require(:label).permit(:id,:name)
    end
end
