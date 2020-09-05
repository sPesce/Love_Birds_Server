class Api::V1::DisabilitiesController < ApplicationController

  def index
    user = find_user
    #logged in will throw error if no user

    render json: user.disabilities, only: [:name]
  end

  def create
    user = find_user
    user.disabilities.build(name: disability_params[:disability].downcase)
    user.validated = false;

    return  render json: {error: "Invalid disability"} unless user.valid?

    user.save
    render json: DisabilitySerializer.new(user.disabilities).serialized_json
    
  end

  private
  def disability_params
    params.permit(:disability)
  end

end
