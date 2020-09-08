class UserCaretakerSerializer
  
  attr_accessor :user, :caretaker, :created
  
  def initialize(user_caretaker)
    self.user = user_caretaker.user
    self.caretaker = user_caretaker.caretaker
    self.created = user_caretaker.created_at
  end

  def serialize
    return {
      user: self.user.email,
      caretaker: self.caretaker.email,
      created: self.created
    }
  end
end
