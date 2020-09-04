class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :first, :last, :email, :bio, :zip_code, :validated, :account_type, :created_at
  attribute :account_complete do |user|
    user.is_complete?
  end
  has_many :disabilities
end
