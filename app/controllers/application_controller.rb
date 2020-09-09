class ApplicationController < ActionController::API
  before_action :logged_in?

  def encode_token(payload)
    JWT.encode(payload, "SERIESOFTUBES", "HS256")
  end

  def decode_token(token)
    JWT.decode(token,"SERIESOFTUBES","HS256")[0]
  end

  def find_user
    token = get_token

    user_id = decode_token(token)["user_id"]
    return User.find(user_id)
  end

  def logged_in?
      begin
          user = find_user
      rescue 
          user = nil
      end
      render json: {error: "Please log in"} unless user
  end

  private
  def get_token
    headers = request.headers["Authorization"]
    token = headers.split(' ')[1]
  end

end
