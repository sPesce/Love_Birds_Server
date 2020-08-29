class UserDisability < ApplicationRecord
  belongs_to :user
  belongs_to :disability
end
