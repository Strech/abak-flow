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
    git = MiniTest::Mock.new
    git.expect :config, oauth_user, ["abak-flow.oauth_user"]
    git.expect :config, oauth_token, ["abak-flow.oauth_token"]
  end

  let(:git) do
    git_without_proxy.expect :config, nil, ["abak-flow.proxy_server"]
  end

  describe "when init config" do
    it "should respond to init" do
      described_class.must_respond_to :init
    end

    it "should raise Exception" do
      class Params < Struct.new(:oauth_user, :oauth_token, :proxy_server); end

      described_class.stub(:init_git_configuration, nil) do
        described_class.stub(:init_environment_configuration, nil) do
          described_class.stub(:params, Params.new) do
            -> { described_class.init }.must_raise Exception
          end

          described_class.stub(:params, Params.new("hello")) do
            -> { described_class.init }.must_raise Exception
          end

          described_class.stub(:params, Params.new("", "hello")) do
            -> { described_class.init }.must_raise Exception
          end
        end
      end
    end
  end

  describe "when check config" do
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
      described_class.stub(:git, git) do
        described_class.stub(:environment_http_proxy, environment) do
          described_class.init
          described_class.proxy_server.must_equal "http://www.linux-proxy.net:6666/"
        end
      end
    end

    it "should set proxy_server from git config" do
      git_without_proxy.expect :config, proxy_server, ["abak-flow.proxy_server"]

      described_class.stub(:git, git) do
        described_class.stub(:environment_http_proxy, nil) do
          described_class.init
          described_class.proxy_server.must_equal "http://www.super-proxy.net:4080/"
        end
      end
    end

    it "should set proxy_server from git config not from environment" do
      git_without_proxy.expect :config, proxy_server, ["abak-flow.proxy_server"]

      described_class.stub(:git, git) do
        described_class.stub(:environment_http_proxy, environment) do
          described_class.init
          described_class.proxy_server.must_equal "http://www.super-proxy.net:4080/"
        end
      end
    end
  end
end