class User < ApplicationRecord
  before_save do |user|
    if(user.zip_code)
      location = Location.find_by(zip: user.zip_code)
      if(location)
        user.location = Location.find_by(zip: user.zip_code)
        
      end
    end
  end

  has_secure_password

  has_one :user_caretaker
  has_one :caretaker, through: :user_caretaker
  
  has_many :user_disabilities
  has_many :disabilities, through: :user_disabilities

  has_many :user_interests
  has_many :interests, through: :user_interests

  has_many :matches
  has_many :matched_user, through: :matches

  belongs_to :location, optional: true

  has_one_attached :main_image

  #because a user can either be the user or the caretaker in user caretaker,
  #this method should be used to find a user_caretaker from a user
  def find_user_caretaker
    uc = UserCaretaker.find_by(user_id: self.id)#self is a standard user
    return uc unless !uc
    return UserCaretaker.find_by(caretaker_id: self.id)#self is a caretaker
  end

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
  #distance in miles from self to another user
  def distance_to(other_user)
    locations = [self,other_user].map{|usr| [usr.location.lat,usr.location.long]}    
    Geocoder::Calculations.distance_between(locations[0],locations[1])    
  end

  #get closest other users, if radius given, then only get ppl close enough
  def get_closest(radius = nil)  
    users = User.all.select{|usr| constraints(radius,usr)}
    users.sort_by{|usr| self.distance_to(usr)}
  end

  def caretaker_of
    uc = UserCaretaker.find_by(caretaker_id: self.id)
    return nil unless (uc && uc.user)
    return uc.user
  end

  private
  #used in get_closest, just adds radius to query
  def constraints(radius = nil,user)
    return (self.id != user.id && self.distance_to(user) <= radius) if (radius)    
    return (self.id != user.id)
  end

 

  

end
