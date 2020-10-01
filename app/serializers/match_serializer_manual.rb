class MatchSerializerManual
  def initialize(match)
    @match = match
  end

  def to_serialized_json
    user_options = 
    {
      include:
      {
        interests: 
        {
          only: [:name]
        },
        disabilities: 
        {
          only: [:name]
        }
      },
      only: [:first,:last,:email,:gender,:pic]          
    }
    options = 
    {
      include: 
      {
        user: user_options,
        matched_user: user_options 
      },
      only: [:sender_status,:reciever_status,:updated_at]
    }
    return @match.to_json(options)
  end

end
