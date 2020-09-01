class User < ApplicationRecord
  has_secure_password

  has_one :user_caretaker
  has_one :caretaker, through: :user_caretaker
  
  has_many :user_disabilities
  has_many :disabilities, through: :user_disabilities

  has_many :user_interests
  has_many :interests, through: :user_interests

  has_many :matches
  has_many :matched_user, through: :matches


  def self.new_initial(params)    
    caretaker,email,password = params.values_at(:caretaker,:email,:password)
    account_type = caretaker ? "caretaker" : "standard"
    User.new(account_type: account_type, email: email, password: password)
  end

  def is_complete?
    case self.account_type
    when "admin"
      return !!(self.email && self.password_digest)
    when "caretaker"
      return !!(self.email && self.password_digest && self.first && self.last)
    when "standard"
      return !self.attributes.values.include?(nil)
    else
      return false
    end
  end

  

end
