class ApplicationController < ActionController::API
  def encode_token(payload)
    JWT.encode(payload, "SERIESOFTUBES", "HS256")
  end

  def decode_token(token)
    JWT.decode(token,"SERIESOFTUBES","HS256")[0]
  end
end
