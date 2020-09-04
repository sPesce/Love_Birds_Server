class Api::V1::DisabilitiesController < ApplicationController

  def index
    user = find_user
    #logged in will throw error if no user

    render json: user.disabilities, only: [:name]
  end

  def create
    user = find_user
    user.disabilities.build(name: disability_params[:disability].downcase)

    return  render json: {error: "Invalid disability"} unless user.valid?

    user.save
    render json: user.disabilities, only: [:name]
    
  end

  private
  def disability_params
    params.permit(:disability)
  end

end
