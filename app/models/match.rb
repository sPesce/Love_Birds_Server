


class Match < ApplicationRecord
  validate :distinct_matches
  
  belongs_to :user
  belongs_to :matched_user, class_name: "User"

  has_many :messages
  
  private
  def distinct_matches
    id = self.id ? self.id : -1
    existing = Match.where.not(id: id).pluck(:user_id,:matched_user_id)
    newRecord = [self.user_id,self.matched_user_id]

    existing.each do |current|
      if((current & newRecord).length == 2)
        self.errors.add(:user_id, "match already exists")
      end
    end
  end

end
