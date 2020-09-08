class Api::V1::UsersController < ApplicationController

  skip_before_action :logged_in?, only: [:create]

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

  def caretaker
    user = find_user
    return render json: {error: "Invalid Token, no user found."} unless user
    
    uc = user.find_user_caretaker
    return render json: {error: "No user/caretaker relationship"} unless uc

    render json: UserCaretakerSerializer.new(uc).serialize
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

  def accept_caretaker
    user = find_user
    uc = user.find_user_caretaker
    uc.accepted = "BOTH"
    uc.save
    return render json: UserCaretakerSerializer.new(uc).serialize
  end

  def caretaker_request
    user = find_user
    return render json: {error: "Invalid Token, no user found"} unless user
    user2 = User.find_by(caretaker_params)
    return render json: {error: "Email provided is not associated with any accounts"} unless user2

    if(user.account_type == user2.account_type)
      if (user.account_type == 'standard')
        return render json: {error: "The user requested is not a caretaker"}
      elsif (user.account_type == 'caretaker')
        return render json: {error: "The resquested user is also a caretaker"}
      end
    elsif(user2.account_type == "admin")
      return render json: {error: "The requested user cannot be a caretaker"}
    end
    
    uc = UserCaretaker.new(accepted: user.email)
    #user should be standard user, caretaker should be caretaker user
    uc.user = user.account_type == 'standard' ? user : user2
    uc.caretaker = user.account_type == 'standard' ? user2 : user

    return render json: {error: "There was an error saving the caretaker"} unless uc.valid?

    uc.save
    return render json: {user: uc.user.email, caretaker: uc.caretaker.email, accepted: uc.accepted}
  end

  def caretaker_remove
    user = find_user
    return render json: {error: "Invalid Token, no user found"} unless user

    uc = user.find_user_caretaker
    return render json: {error: "Invalid Request, no user caretaker relationship found"} unless uc

    user2 = user.caretaker_of

    return render json: {error: "There was a problem removing the user caretaker relationship"} unless uc.destroy

    return render json: {success: "The current user is no longer a caretaker to #{user2.email}"}
  end

  private
  def user_params
    params.require(:user).permit(:email,:password,:caretaker,:first,:last,:bio,:zip_code,:gender,:match_gender)  
  end

  def matching_params
    params.permit(:radius)
  end

  def caretaker_params
    params.require(:user).permit(:email)
  end
  
end
