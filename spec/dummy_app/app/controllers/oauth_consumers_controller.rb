require 'oauth/controllers/consumer_controller'
class OauthConsumersController < ApplicationController
  include Oauth::Controllers::ConsumerController
  # Replace this with the equivalent for your authentication framework
  # Eg. for devise
  #
  #   before_filter :authenticate_user!, :only=>:index
  before_filter :login_required, :only=>:index

  def index
    @consumer_tokens=ConsumerToken.all :conditions=>{:user_id=>current_user.id}
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
  end

  def callback
  	super
  end

  def client
    super
  end


  protected

  # Change this to decide where you want to redirect user to after callback is finished.
  # params[:id] holds the service name so you could use this to redirect to various parts
  # of your application depending on what service you're connecting to.
  def go_back
    redirect_to root_url
  end

  def logged_in?
    current_user != nil
  end

  def current_user
    session[:user]
  end

  def current_user=(user)
    session[:user] = user
  end

  # Override this to deny the user or redirect to a login screen depending on your framework and app
  # if different. eg. for devise:
  #
  # def deny_access!
  #   raise Acl9::AccessDenied
  # end
end
