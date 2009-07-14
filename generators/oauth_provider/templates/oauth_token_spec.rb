require File.dirname(__FILE__) + '/../spec_helper'

describe RequestToken do
  fixtures :client_applications, :users, :oauth_tokens
  before(:each) do
    @token = RequestToken.create :client_application => client_applications(:one)
  end

  it "should be valid" do
    @token.should be_valid
  end
  
  it "should not have errors" do
    @token.errors.should_not == []
  end
  
  it "should have a token" do
    @token.token.should_not be_nil
  end

  it "should have a secret" do
    @token.secret.should_not be_nil
  end
  
  it "should not be authorized" do 
    @token.should_not be_authorized
  end

  it "should not be invalidated" do
    @token.should_not be_invalidated
  end
  
  it "should not have a verifier" do
    @token.verifier.should be_nil
  end
  
  describe "authorize request" do
    before(:each) do
      @token.authorize!(users(:quentin))      
    end
    
    it "should be authorized" do
      @token.should be_authorized      
    end
    
    it "should have authorized at" do
      @token.authorized_at.should_not be_nil      
    end
    
    it "should have user set" do
      @token.user.should == users(:quentin)      
    end
    
    it "should have verifier" do
      @token.verifier.should_not be_nil      
    end
    
    describe "exchange for access token" do
      
      before(:each) do
        @token.provided_oauth_verifier=@token.verifier
        @access = @token.exchange!
      end
      
      it "should invalidate request token" do
        @token.should be_invalidated
      end
      
      it "should set user on access token" do
        @access.user.should == users(:quentin)        
      end
      
      it "should authorize accesstoken" do
        @access.should be_authorized        
      end
    end

    describe "attempt exchange with invalid verifier" do
      
      before(:each) do
        @value = @token.exchange!
      end
      
      it "should return false" do
        @value.should==false
      end
      
      it "should not invalidate request token" do
        @token.should_not be_invalidated
      end
    end

  end
  
  describe "attempt exchange with out authorization invalid verifier" do
    
    before(:each) do
      @value = @token.exchange!
    end
    
    it "should return false" do
      @value.should==false
    end
    
    it "should not invalidate request token" do
      @token.should_not be_invalidated
    end
  end
  
  it "should return 1.0 style to_query without token callback url" do
    @token.to_query.should=="oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
  end
  
  describe "setting a token callback url" do
    
    before(:each) do
      @token.callback_url="http://test.com/callback"      
    end

    it "should return 1.0a style to_query with token callback url" do    
      @token.to_query.should=="oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
    end

  end
  
end
