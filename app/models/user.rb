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

  belongs_to :location, optional: true

  has_one_attached :main_image

  def matched_users
    Match.where(user_id: self.id) + Match.where(matched_user_id: self.id)
  end

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
      return !!self.email
    when "caretaker"
      return !!(self.email && self.first && self.last)
    when "standard"
      return !!(self.first && 
      self.last && 
      self.email &&
      self.bio &&
      self.zip_code &&
      self.gender &&
      self.match_gender
        )
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
  def get_closest(radius = 999999999999999999999999999999999999999.9)
    
    users = User.all.select{|usr| constraints(radius,usr)}
    return false if !users

    users.sort_by{|usr| self.distance_to(usr)}[0..(users.length < 25 ? users.length - 1 : 24)]
  end

  def caretaker_of
    uc = UserCaretaker.find_by(caretaker_id: self.id)
    return nil unless (uc && uc.user)
    return uc.user
  end

  def full_name
    return (self.first + " " + self.last).titlecase() 
  end

  #only to be used for seeding bio
  def interests_string
    interests = self.interests.pluck(:name)
    return  (['only ','just '].sample + interests[-1]) if (interests.length <= 1)
    memo = interests[0,interests.length - 1].join(", ")
    memo += " and " + interests[-1]
    memo
  end  

  private
  #used in get_closest, just adds radius to query
  def constraints(radius = nil,user)
    return false if (self.matched_users.include?(user))
    return false if (user.matched_users.include?(self))
    if(self.match_gender != 'any' && self.match_gender != user.gender)
      return false
    end
    if(user.match_gender != 'any' && user.match_gender != self.gender)
      return false
    end
    return false if (self.id == user.id)
    return false if ( self.distance_to(user) > radius)
    return true    
  end
end
