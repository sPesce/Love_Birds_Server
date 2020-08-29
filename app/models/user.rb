class User < ApplicationRecord
  has_one :user_caretaker
  has_one :caretaker, through: :user_caretaker
  
  has_many :user_disabilities
  has_many :disabilities, through: :user_disabilities

  has_many :user_interests
  has_many :interests, through: :user_interests

  has_many :matches
  has_many :matched_user, through: :matches



  #TODO: FAST JSON API -----------------------------------
  #_----------------------------------//p0psdft0pasd0gf000

end
