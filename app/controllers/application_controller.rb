class ApplicationController < ActionController::API
  def encode_token(payload)
    JWT.encode(payload, "SERIESOFTUBES", "HS256")
  end

  def decode_token(token)
    JWT.decode(token,"SERIESOFTUBES","HS256")[0]
  end

  def find_user
    headers = request.headers["Authorization"]
    token = headers.split(' ')[1]

    user_id = decode_token(token)["user_id"]
    return User.find(user_id)
  end
end
