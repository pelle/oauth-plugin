require 'spec_helper'

describe Oauth2Token do 
  let(:token) { Oauth2Token.new.save }
  subject { token }

  its(:token) {should be}
  its(:token_digest) {should == Digest::SHA1.hexdigest( token.token )}
  it { should be_valid}
  it { should be_authorized }
  it { should_not be_invalidated }
end
