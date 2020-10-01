class Api::V1::MatchesController < ApplicationController

  def index
    user = find_user
    matches = []
    match_list = []
    
    if(user.account_type === 'standard')
      matches_to = Match.where(matched_user_id: user.id)
      matches_from = Match.where(user_id: user.id)
      matches = matches_to + matches_from  
    else
      to_standard = Matches.where(matched_user_id: user.caretaker_to.id)
      from_standard = Matches.where(user_id: user.caretaker_to.id)
      return render json: {error: 'no matches'} if !matches
      matches = (to_standard + from_standard)
    end
    return render json: {error: 'no matches'} if !matches

    matches.each do |m|
      other_user = m.other_user(user) 
      currentMatch = 
      {
        sender_email: m.user.email,        
        reciever_email: m.matched_user.email,  
        sender_status: m.sender_status,
        reciever_status: m.reciever_status,  
        id: m.id,
        user: UserSerializerManual.new(other_user).to_serialized_json
      }
      match_list.push(currentMatch)
    end
    render json: {matches: match_list}
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

    render json: {
      sender: m.user.email,
      sender_status: m.sender_status,
      reciever_status: m.reciever_status,
      sender_name: m.user.first,
      id: m.id
    }
    
  end

  private
  def accept_params
    params.require(:match).permit(:id,:accept)
  end

end
