class Message < ApplicationRecord
  belongs_to :user_id
  belongs_to :match_id
end
