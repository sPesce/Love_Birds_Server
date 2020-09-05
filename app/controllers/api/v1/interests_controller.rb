class Api::V1::InterestsController < ApplicationController

  

  def create
    user = find_user
    user.interests.build(name: interests_params[:interest].downcase)

    return  render json: {error: "Invalid interest"} unless user.valid?

    user.save
    render json: InterestSerializer.new(user.interests).serialized_json
    
  end

  private
  def interests_params
    params.permit(:interest)
  end
end
