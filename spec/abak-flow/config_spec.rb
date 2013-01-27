# coding: utf-8
require "spec_helper"
require "abak-flow/config"

describe Abak::Flow::Config do
  let(:described_class) { Abak::Flow::Config }

  let(:oauth_user) { "Admin" }
  let(:oauth_token) { "0123456789" }
  let(:proxy_server) { "http://www.super-proxy.net:4080/" }
  let(:environment) { "http://www.linux-proxy.net:6666/" }

  let(:git_without_proxy) do
    GitMock.new nil, nil, nil, {
      "abak-flow.oauth_user" => oauth_user,
      "abak-flow.oauth_token" => oauth_token,
      "abak-flow.proxy_server" => nil
    }
  end

  let(:git) do
    GitMock.new nil, nil, nil, {
      "abak-flow.oauth_user" => oauth_user,
      "abak-flow.oauth_token" => oauth_token,
      "abak-flow.proxy_server" => proxy_server
    }
  end

  describe "when init config" do
    it { described_class.must_respond_to :init }
    it { described_class.must_respond_to :params }

    it "should raise Exception" do
      class Params < Struct.new(:oauth_user, :oauth_token, :proxy_server); end

      described_class.stub(:init_git_configuration, nil) do
        described_class.stub(:init_environment_configuration, nil) do
          described_class.stub(:params, Params.new) do
            described_class.init
            -> { described_class.check_requirements }.must_raise Exception
          end

          described_class.stub(:params, Params.new("hello")) do
            described_class.init
            -> { described_class.check_requirements }.must_raise Exception
          end

          described_class.stub(:params, Params.new("", "hello")) do
            described_class.init
            -> { described_class.check_requirements }.must_raise Exception
          end
        end
      end
    end
  end

  describe "when check config" do
    describe "when all config elements missing" do
      let(:git) do
        git = GitMock.new nil, nil, nil, {
          "abak-flow.oauth_user" => nil,
          "abak-flow.oauth_token" => nil,
          "abak-flow.proxy_server" => nil
        }
      end

      it "should be nil when ask oauth_user" do
        described_class.stub(:git, git) do
          described_class.init
          described_class.oauth_user.must_equal nil
        end
      end

      it "should be nil when ask oauth_token" do
        described_class.stub(:git, git) do
          described_class.init
          described_class.oauth_token.must_equal nil
        end
      end
    end

    it "should take oauth_user from git config" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.oauth_user.must_equal "Admin"
      end
    end

    it "should take oauth_token from git config" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.oauth_token.must_equal "0123456789"
      end
    end

    it "should set proxy_server from environment" do
      git.config.merge!({"abak-flow.proxy_server" => nil})

      described_class.stub(:git, git) do
        described_class.stub(:environment_http_proxy, environment) do
          described_class.init
          described_class.proxy_server.must_equal "http://www.linux-proxy.net:6666/"
        end
      end
    end

    it "should set proxy_server from git config" do
      described_class.stub(:git, git) do
        described_class.stub(:environment_http_proxy, nil) do
          described_class.init
          described_class.proxy_server.must_equal "http://www.super-proxy.net:4080/"
        end
      end
    end

    it "should set proxy_server from git config not from environment" do
      described_class.stub(:git, git) do
        described_class.stub(:environment_http_proxy, environment) do
          described_class.init
          described_class.proxy_server.must_equal "http://www.super-proxy.net:4080/"
        end
      end
    end
  end
end