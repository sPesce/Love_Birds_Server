class Api::V1::UsersController < ApplicationController
  def create
    user = User.new_initial(user_params)
    if user.valid?
      #seperate from model validations, 
      user.validated = false
      user.save
      render json: {token: encode_token({user_id: user.id})}
    else
      render json: {error: "invalid email or password"}
    end
  end

  def find
    user = find_user
    if user
      options = {include: [:disabilities,:interests]}
      render json: UserSerializer.new(user,options).serialized_json
    else
      render json: {error: "Invalid Token, no user found."}
    end
  end

  def update
    user = find_user
    if user      
      user.assign_attributes(user_params)
    end

    return  render json: {error: "Invalid Token, no user found."} unless user.valid?

    user.save
    options = {include: [:disabilities]}
    
    render json: UserSerializer.new(user, options).serialized_json
        
  end

  def get_closest_matches
    user = find_user
    render json: {error: "Invalid Token, no user found"} unless user

    radius = matching_params[:radius] ? matching_params[:radius] : nil
    matches = user.get_closest(radius)
    if(!matches[0])
      render json: {error: "No matches found in radius"}
    else
      render json: matches.to_json(:include => 
      {
        :interests => {:only => [:name]}
      }, only: [:first,:last,:bio,:zip_code])
    end

  end

  private
  def user_params
    params.require(:user).permit(:email,:password,:caretaker,:first,:last,:bio,:zip_code)  
  end

  def matching_params
    params.permit(:radius)
  end
  
end
