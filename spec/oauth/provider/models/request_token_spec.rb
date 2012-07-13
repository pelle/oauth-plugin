require 'spec_helper'

describe RequestToken do 
  let(:token) { RequestToken.new.save }
  let(:user) { double("user") }
  subject { token }

  its(:token) {should be}
  its(:secret) {should be}
  its(:token_digest) {should == Digest::SHA1.hexdigest( token.token )}
  it { should be_valid}
  it { should_not be_authorized }
  it { should_not be_invalidated }

  describe "Authorizing" do
    before(:each) { token.authorize!(user) }
    its(:user) { should == user }
    its(:verifier) { should be}
    it { should be_authorized }
  end
end
