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

module Abak::Flow::PullRequest::Branches
  class << self
    attr_accessor :current_branch
  end
end

class CurrentBranchMock < Struct.new(:task)
  def task?; task end
end

describe Abak::Flow::PullRequest do
  describe "Methods of instance" do
    subject { Abak::Flow::PullRequest.new }

    it { subject.must_respond_to :valid? }
    it { subject.must_respond_to :invalid? }
    it { subject.must_respond_to :recommendations }
    it { subject.must_respond_to :publish }
    it { subject.must_respond_to :publish! }
  end

  describe "Initialize process" do
    before do
      Abak::Flow::PullRequest::System.ready = true
      Abak::Flow::PullRequest::System.recommendations = []
    end

    let(:attributes) { {target: "develop", title: "Fix some problem", body: "Check this request"} }
    subject { Abak::Flow::PullRequest.new(attributes) }

    it { subject.options.wont_be_nil }
    it { subject.recommendations.must_be_empty }
  end

  describe "Pushing process" do
    subject { Abak::Flow::PullRequest.new }

    describe "when something goes wrong" do
      describe "when system is not ready" do
        before { Abak::Flow::PullRequest::System.ready = false }

        it { subject.publish.must_equal false }
      end

      describe "when pull request is invalid" do
        before { Abak::Flow::PullRequest::System.ready = true }

        it "should be false" do
          subject.stub(:invalid?, true) do
            subject.publish.must_equal false
          end
        end
      end
    end

    describe "when all right" do
      before { Abak::Flow::PullRequest::System.ready = true }

      it "shoud return true" do
        subject.stub(:requirements_satisfied?, true) do
          subject.publish.must_equal true
        end
      end

    end

    describe "when use bang! method" do
      describe "when something goes wrong" do
        before { Abak::Flow::PullRequest::System.ready = false }

        it { -> { subject.publish! }.must_raise Exception }
      end

      describe "when all right" do
        before { Abak::Flow::PullRequest::System.ready = true }

        it "shoud not raise Exception" do
          subject.stub(:requirements_satisfied?, true) do
            -> { subject.publish! }.must_be_silent
          end
        end
      end
    end

  end

  describe "Validation process" do
    describe "when system is not ready" do
      before do
        Abak::Flow::PullRequest::System.ready = false
        Abak::Flow::PullRequest::System.recommendations = %w[one two three]
      end

      subject { Abak::Flow::PullRequest.new }

      describe "when pull request is valid" do
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
        it "should have only system recommendations" do
          subject.stub(:requirements_satisfied?, false) do
            subject.valid?
            subject.recommendations.must_equal %w[one two three]
          end
        end
      end
    end

    describe "when system is ready" do
      before do
        Abak::Flow::PullRequest::System.ready = true
        Abak::Flow::PullRequest::System.recommendations = []
      end

      subject { Abak::Flow::PullRequest.new }

      describe "when pull request is valid" do
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

        it "should not have system recommendations" do
          subject.stub(:requirements_satisfied?, true) do
            subject.valid?
            subject.recommendations.must_be_empty
          end
        end
      end

      describe "when pull request is invalid" do
        before do
          Abak::Flow::PullRequest::Branches.current_branch = CurrentBranchMock.new(false)
        end

        it "should not satisfy requirements" do
          subject.send(:requirements_satisfied?).must_equal false
        end

        it "should have recommendations" do
          subject.stub(:specify_title_recommendation, "hello") do
            subject.valid?
            subject.recommendations.must_equal %w[hello]
          end
        end
      end
    end

  end
end