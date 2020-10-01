class UserSerializerManual
  def initialize(user)
    @user = user
  end

  def to_serialized_json
    options = {
      include: {
        interests: {
          only: [:name]
        },
        disabilities: {
          only: [:name]
        }
      },
      only: [:first,:last,:email,:gender,:pic]
    }
    return @user.to_json(options)
  end

end