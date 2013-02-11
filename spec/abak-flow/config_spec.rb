# coding: utf-8
require "spec_helper"

module Abak::Flow::Config
  class I18n
    class << self
      attr_accessor :load_path
    end
  end
end

require "abak-flow/config"

describe Abak::Flow::Config do
  subject { Abak::Flow::Config }

  let(:oauth_user) { "Admin" }
  let(:oauth_token) { "0123456789" }
  let(:proxy_server) { "http://www.super-proxy.net:4080/" }
  let(:environment) { "http://www.linux-proxy.net:6666/" }

  let(:git_without_proxy) do
    GitMock.new nil, nil, nil, {
      "abak-flow.oauth-user" => oauth_user,
      "abak-flow.oauth-token" => oauth_token,
      "abak-flow.proxy-server" => nil,
      "abak-flow.locale" => nil
    }
  end

  let(:git) do
    GitMock.new nil, nil, nil, {
      "abak-flow.oauth-user" => oauth_user,
      "abak-flow.oauth-token" => oauth_token,
      "abak-flow.proxy-server" => proxy_server,
      "abak-flow.locale" => "ru"
    }
  end

  before { Abak::Flow::Config::I18n.load_path = [] }

  describe "when init config" do
    it { subject.must_respond_to :init }
    it { subject.must_respond_to :params }

    it "should raise Exception" do
      class Params < Struct.new(:oauth_user, :oauth_token, :proxy_server, :locale); end

      subject.stub(:init_git_configuration, nil) do
        subject.stub(:init_environment_configuration, nil) do
          subject.stub(:need_initialize?, true) do
            subject.stub(:params, Params.new) do
              subject.init
              -> { subject.check_requirements }.must_raise Exception
            end

            subject.stub(:params, Params.new("hello")) do
              subject.init
              -> { subject.check_requirements }.must_raise Exception
            end

            subject.stub(:params, Params.new("", "hello")) do
              subject.init
              -> { subject.check_requirements }.must_raise Exception
            end
          end
        end
      end
    end

    it "should not initialize config if already initialized" do
      subject.stub(:initialized, true) do
        subject.stub(:init_git_configuration, -> { raise Exception }) do
          -> { subject.init }.must_be_silent
        end
      end
    end

    it "should initialize config if not initialized" do
      subject.stub(:initialized, false) do
        subject.stub(:init_git_configuration, -> { raise Exception }) do
          -> { subject.init }.must_raise Exception
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
          "abak-flow.proxy_server" => nil,
          "abak-flow.locale" => nil
        }
      end

      it "should be nil when ask oauth_user" do
        subject.stub(:git, git) do
          subject.stub(:need_initialize?, true) do
            subject.init
            subject.oauth_user.must_equal nil
          end
        end
      end

      it "should be nil when ask oauth_token" do
        subject.stub(:git, git) do
          subject.stub(:need_initialize?, true) do
            subject.init
            subject.oauth_token.must_equal nil
          end
        end
      end

      it "should set locale to default en" do
        subject.stub(:git, git) do
          subject.stub(:need_initialize?, true) do
            subject.init
            subject.locale.must_equal "en"
          end
        end
      end
    end

    it "should take oauth_user from git config" do
      subject.stub(:git, git) do
        subject.stub(:need_initialize?, true) do
          subject.init
          subject.oauth_user.must_equal "Admin"
        end
      end
    end

    it "should take oauth_token from git config" do
      subject.stub(:git, git) do
        subject.stub(:need_initialize?, true) do
          subject.init
          subject.oauth_token.must_equal "0123456789"
        end
      end
    end

    it "should set locale to :en" do
      subject.stub(:git, git) do
        subject.stub(:need_initialize?, true) do
          subject.init
          subject.locale.must_equal "ru"
        end
      end
    end

    it "should set proxy_server from environment" do
      git.config.merge!({"abak-flow.proxy-server" => nil})

      subject.stub(:git, git) do
        subject.stub(:environment_http_proxy, environment) do
          subject.stub(:need_initialize?, true) do
            subject.init
            subject.proxy_server.must_equal "http://www.linux-proxy.net:6666/"
          end
        end
      end
    end

    it "should set proxy_server from git config" do
      subject.stub(:git, git) do
        subject.stub(:environment_http_proxy, nil) do
          subject.stub(:need_initialize?, true) do
            subject.init
            subject.proxy_server.must_equal "http://www.super-proxy.net:4080/"
          end
        end
      end
    end

    it "should set proxy_server from git config not from environment" do
      subject.stub(:git, git) do
        subject.stub(:environment_http_proxy, environment) do
          subject.stub(:need_initialize?, true) do
            subject.init
            subject.proxy_server.must_equal "http://www.super-proxy.net:4080/"
          end
        end
      end
    end
  end
end