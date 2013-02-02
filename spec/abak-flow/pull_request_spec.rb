# coding: utf-8
require "spec_helper"
require "abak-flow/pull_request"

# Stubs
module Abak::Flow::PullRequest::Project
  def self.init; end
end

module Abak::Flow::PullRequest::Config
  def self.init; end
end

module Abak::Flow::PullRequest::System
  class << self
    attr_accessor :ready, :recommendations

    def ready?; ready end
  end
end

describe Abak::Flow::PullRequest do
  let(:attributes) { {target: "develop", title: "Fix some problem", body: "Check this request"} }

  describe "Methods of instance" do
    subject { Abak::Flow::PullRequest.new }

    it { subject.must_respond_to :valid? }
    it { subject.must_respond_to :invalid? }
    it { subject.must_respond_to :recommendations }
  end

  describe "when system is not ready" do
    before do
      Abak::Flow::PullRequest::System.ready = false
      Abak::Flow::PullRequest::System.recommendations = %w[one two three]
    end

    describe "when pull request is valid" do
      subject { Abak::Flow::PullRequest.new }

      it "should not be valid pull request" do
        subject.stub(:requirements_satisfied?, true) do
          subject.valid?.must_equal false
        end
      end

      it "should be invalid request" do
        subject.stub(:requirements_satisfied?, true) do
          subject.invalid?.must_equal true
        end
      end

      it "should have system recommendations" do
        subject.stub(:requirements_satisfied?, true) do
          subject.valid?
          subject.recommendations.must_equal %w[one two three]
        end
      end
    end

    describe "when pull request is invalid" do
      # ...
    end
  end

  describe "when system is ready" do
    before do
      Abak::Flow::PullRequest::System.ready = true
      Abak::Flow::PullRequest::System.recommendations = []
    end

    describe "when pull request is valid" do
      subject { Abak::Flow::PullRequest.new }

      it "should be valid pull request" do
        subject.stub(:requirements_satisfied?, true) do
          subject.valid?.must_equal true
        end
      end

      it "should not be invalid request" do
        subject.stub(:requirements_satisfied?, true) do
          subject.invalid?.must_equal false
        end
      end

      it "should have system recommendations" do
        subject.stub(:requirements_satisfied?, true) do
          subject.valid?
          subject.recommendations.must_be_empty
        end
      end
    end

    describe "when pull request is invalid" do
      # ...
    end
  end
end