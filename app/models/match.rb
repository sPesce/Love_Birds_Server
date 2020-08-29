class Match < ApplicationRecord
  belongs_to :user
  belongs_to :matched_user, class_name: "User"
  
  has_one :chat
  has_many :messages, through: :chat
end
