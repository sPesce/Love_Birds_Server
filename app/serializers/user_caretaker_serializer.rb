class UserCaretakerSerializer
  
  attr_accessor :user, :caretaker, :created, :accepted
  
  def initialize(user_caretaker)
    self.user = user_caretaker.user
    self.caretaker = user_caretaker.caretaker
    self.created = user_caretaker.created_at
    self.accepted = user_caretaker.accepted
  end

  def serialize
    return {
      user: self.user.email,
      caretaker: self.caretaker.email,
      accepted: self.accepted,
      created: self.created
    }
  end
end
