class ConsumerToken
  include Mongoid::Document
  include Mongoid::Timestamps
  include Oauth::Models::Consumers::Token

  field :token, :type => String
  field :secret, :type => String
  field :type, :type => String

  index :token, :unique => true

  referenced_in :user

end
