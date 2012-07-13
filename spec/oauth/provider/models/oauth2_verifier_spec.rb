require 'spec_helper'

describe Oauth2Verifier do 
  let(:token) { Oauth2Verifier.new.save }
  subject { token }

  its(:token) {should be}
  its(:code) {should == token.token }
  its(:token_digest) {should == Digest::SHA1.hexdigest( token.token )}
  it { should be_valid}
  it { should be_authorized }
  it { should_not be_invalidated }
end
