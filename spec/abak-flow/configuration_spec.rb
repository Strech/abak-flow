# coding: utf-8
require "spec_helper"

describe Abak::Flow::Configuration do
  let(:oauth_user) { "Admin" }
  let(:oauth_token) { "0123456789" }
  let(:proxy_server) { "http://www.super-proxy.net:4080/" }
  let(:environment) { "http://www.linux-proxy.net:6666/" }
  let(:instance) { described_class.clone.instance }

  let(:git) do
    double("Git Config", config: {
      "abak-flow.oauth-user" => oauth_user,
      "abak-flow.oauth-token" => oauth_token,
      "abak-flow.proxy-server" => proxy_server,
      "abak-flow.locale" => "ru"
    })
  end

  context "when all config elements missing" do
    let(:git) { double("Git Config", config: {}) }

    before do
      described_class.any_instance.stub(:environment_http_proxy).and_return nil
      described_class.any_instance.stub(:git).and_return git
      described_class.any_instance.stub(:setup_locale)
    end

    subject { instance.params }

    its(:oauth_user) { should be_nil }
    its(:oauth_token) { should be_nil }
    its(:proxy_server) { should be_nil }
    its(:locale) { should eq "en" }
  end

  context "when all config elements exists" do
    before do
      described_class.any_instance.stub(:environment_http_proxy).and_return nil
      described_class.any_instance.stub(:git).and_return git
      described_class.any_instance.stub(:setup_locale)
    end

    subject { instance.params }

    its(:oauth_user) { should eq "Admin" }
    its(:oauth_token) { should eq "0123456789" }
    its(:locale) { should eq "ru" }
    its(:proxy_server) { should eq "http://www.super-proxy.net:4080/" }
  end

  context "when various proxy server set" do
    before do
      described_class.any_instance.stub(:git).and_return git
      described_class.any_instance.stub(:setup_locale)
    end

    subject { instance.params.proxy_server }

    context "when ENV and git config setup proxy server" do
      before { described_class.any_instance.stub(:environment_http_proxy).and_return environment }

      it { should eq "http://www.super-proxy.net:4080/" }
    end

    context "when only ENV setup proxy server" do
      before { described_class.any_instance.stub(:environment_http_proxy).and_return environment }
      before { git.stub(:config).and_return({}) }

      it { should eq "http://www.linux-proxy.net:6666/" }
    end
  end
end