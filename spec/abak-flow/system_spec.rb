# coding: utf-8
require "spec_helper"

describe Abak::Flow::System do
  let(:instance) { described_class.clone.instance }
  let(:remotes) { {origin: "origin_repo", upstream: "upstream_repo"} }
  let(:params) { double("Params", oauth_user: "User", oauth_token: "Token", proxy_server: "http://proxy.com", locale: "en") }
  let(:empty_params) { double("Params", oauth_user: nil, oauth_token: nil, proxy_server: nil, locale: nil) }

  describe "#ready?" do
    subject { instance.ready? }

    context "when all requirements is not set" do
      before do
        Abak::Flow::Project.any_instance.stub(:remotes).and_return({})
        Abak::Flow::Configuration.any_instance.stub(:params).and_return empty_params
      end

      it { should be_false }
    end

    context "when upstream is not set" do
      before do
        Abak::Flow::Project.any_instance.stub(:remotes).and_return({origin: "not_nil"})
        Abak::Flow::Configuration.any_instance.stub(:params).and_return params
      end

      it { should be_false }
    end

    context "when origin is not set" do
      before do
        Abak::Flow::Project.any_instance.stub(:remotes).and_return({upstream: "not_nil"})
        Abak::Flow::Configuration.any_instance.stub(:params).and_return params
      end

      it { should be_false }
    end

    context "when all config params is not set" do
      before do
        Abak::Flow::Project.any_instance.stub(:remotes).and_return remotes
        Abak::Flow::Configuration.any_instance.stub(:params).and_return empty_params
      end

      it { should be_false }
    end

    context "when proxy server config is not set" do
      before do
        params.stub(:proxy).and_return nil

        Abak::Flow::Project.any_instance.stub(:remotes).and_return remotes
        Abak::Flow::Configuration.any_instance.stub(:params).and_return params
      end

      it { should be_true }
    end

    context "when all config params is set" do
      before do
        Abak::Flow::Project.any_instance.stub(:remotes).and_return remotes
        Abak::Flow::Configuration.any_instance.stub(:params).and_return params
      end

      it { should be_true }
    end
  end

  describe "#information" do
    context "when proxy is set" do
      before do
        Abak::Flow::Project.any_instance.stub(:remotes).and_return remotes
        Abak::Flow::Configuration.any_instance.stub(:params).and_return params
      end

      before { instance.ready? }
      subject { instance.information }

      it { should_not be_empty }
    end

    context "when proxy is not set" do
      before do
        params.stub(:proxy_server).and_return nil

        Abak::Flow::Project.any_instance.stub(:remotes).and_return remotes
        Abak::Flow::Configuration.any_instance.stub(:params).and_return params
      end

      before { instance.ready? }
      subject { instance.information }

      it { should be_empty }
    end
  end
end