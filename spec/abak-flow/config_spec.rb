# coding: utf-8
require "spec_helper"
require "abak-flow/config"

describe Abak::Flow::Config do
  let(:described_class) { Abak::Flow::Config }

  describe "when init config" do
    it "should respond to init" do
      described_class.must_respond_to :init
    end
    
    it "should take oauth_user from git config" do
      described_class.init
      described_class.oauth_user.must_equal "Admin"
    end
    
    it "should take oauth_token from git config" do
      described_class.init
      described_class.oauth_token.must_equal "0123456789"
    end

    # Проверить api_user api_token
    # Проверить proxy
  end
end