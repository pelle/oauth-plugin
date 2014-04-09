class OauthClientsController < ApplicationController
  before_filter :login_required
  before_filter :get_client_application, :only => [:show, :edit, :update, :destroy]

  def index
    @client_applications = current_user.client_applications
    @tokens = current_user.tokens.find :all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null'
  end

  def new
    @client_application = ClientApplication.new
  end

  def create
    @client_application = current_user.client_applications.build(params[:client_application])
    if @client_application.save
      set_flash_message :notice, "created"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  def show
  end

  def edit
  end

  def update
    if @client_application.update_attributes(params[:client_application])
      set_flash_message :notice, "updated"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application.destroy
    set_flash_message :notice, "destroyed"
    redirect_to :action => "index"
  end
  
  protected
  # Sets the flash message with :key, using I18n.
  # Example (i18n locale file):
  #
  #   en:
  #     oauth_plugin:
  #       oauth:
  #         #messages
  #
  # Please refer to README or en.yml locale file to check what messages are
  # available.
  def set_flash_message(key, kind, options={})
    options[:scope] = "oauth_plugin.#{controller_name}"
    client_app_name = @client_application ? @client_application.name : ''
    options[:client_app_name] = client_app_name
    message = I18n.t("#{kind}", options)
    flash[key] = message if message.present?
  end
  

  private
  def get_client_application
    unless @client_application = current_user.client_applications.find(params[:id])
      set_flash_message :error, "error.application_not_found"
      raise ActiveRecord::RecordNotFound
    end
  end
end
