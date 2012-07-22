require 'oauth/models/consumers/token'
class ConsumerToken < ActiveRecord::Base
  include Oauth::Models::Consumers::Token

  # You can safely remove this callback if you don't allow login from any of your services
  before_validation :create_user_if_create

  # Modify this with class_name etc to match your application
  belongs_to :user

end