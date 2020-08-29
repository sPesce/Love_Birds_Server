class Disability < ApplicationRecord
  has_many :user_disabilities
  has_many :users, through: :user_disabilities
end
