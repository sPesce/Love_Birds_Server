class Api::V1::MatchesController < ApplicationController

  def index
    user = find_user
    matches = user.all_matches
    return render json: {error: 'no matches'} if !matches

    render json: MatchSerializerManual.new(matches).to_serialized_json
  end

  def accept_match
    user = find_user
    match = Match.find_by(id: accept_params[:id])
    accepted = accept_params[:accept]

    reciever_status = !accepted ? -1 : (user.caretaker ? 1 : 2)

    match.update(reciever_status: reciever_status)

    return render json: {error: "problem patching match"} unless match.valid?
    match.save
    m = match

    render json: MatchSerializerManual.new(match).to_serialized_json
    
  end

  private
  def accept_params
    params.require(:match).permit(:id,:accept)
  end

end
