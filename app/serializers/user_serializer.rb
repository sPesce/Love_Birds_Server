class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :first, :last, :email, :bio, :zip_code, :validated, :account_type, :gender, :match_gender, :created_at
  attribute :account_complete do |user|
    user.is_complete?
  end
  has_many :disabilities, serializer: DisabilitySerializer
  has_many :interests, serializer: InterestSerializer
end
