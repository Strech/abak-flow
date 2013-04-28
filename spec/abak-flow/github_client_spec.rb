# coding: utf-8
require "spec_helper"

describe Abak::Flow::GithubClient do
  let(:instance) { described_class.clone.instance }

  describe "#connection" do
    let(:options) { {login: "login", password: "password"} }

    before { described_class.any_instance.stub(:connection_options).and_return options }
    after { instance.connection }

    it { Octokit::Client.should_receive(:new).with({login: "login", password: "password"}) }
  end
end