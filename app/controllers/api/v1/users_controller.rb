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
      render json: UserSerializer.new(user).serialized_json
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

    render json: UserSerializer.new(user).serialized_json
        
  end

  private
  def user_params
    params.require(:user).permit(:email,:password,:caretaker,:first,:last,:bio,:zip_code)  
  end
  
end
