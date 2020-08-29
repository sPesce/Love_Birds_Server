class UserCaretaker < ApplicationRecord
  belongs_to :user
  belongs_to :caretaker, class_name: "User"
end
