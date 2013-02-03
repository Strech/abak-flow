# coding: utf-8
require "spec_helper"
#require "abak-flow/pull_request"

# Stubs
class Abak::Flow::PullRequest
  module Git
    def self.git; end
  end

  module GithubClient
    def self.connection; end
  end

  module Project
    def self.init; end
  end

  module Config
    def self.init; end
  end

  module System
    class << self
      attr_accessor :ready, :recommendations

      def ready?; ready end
    end
  end

  module Branches
    class << self
      attr_accessor :current_branch
    end
  end
end

# TODO : Переписать
class CurrentBranchMock < Struct.new(:tracker_task, :type)
  def task?; tracker_task end
  def feature?; type == "feature" end
  def hotfix?; type == "hotfix" end
end

require "abak-flow/pull_request"

describe Abak::Flow::PullRequest do
  describe "Methods of instance" do
    subject { Abak::Flow::PullRequest.new }

    it { subject.must_respond_to :valid? }
    it { subject.must_respond_to :invalid? }
    it { subject.must_respond_to :publish }
    it { subject.must_respond_to :publish! }

    it { subject.must_respond_to :recommendations }
    it { subject.must_respond_to :github_link }
    it { subject.must_respond_to :exception }
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

  describe "Inner methods" do
    describe "#title" do
      describe "when have only branch name" do
        let(:branch) { CurrentBranchMock.new "hello" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new }

        it { subject.send(:title).must_equal "hello" }
      end

      describe "when have only option task" do
        let(:branch) { CurrentBranchMock.new nil }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new({title: "megusta"}) }

        it { subject.send(:title).must_equal "megusta" }
      end

      describe "when have option task and branch name" do
        let(:branch) { CurrentBranchMock.new "tako" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new({title: "burito"}) }

        it { subject.send(:title).must_equal "tako :: burito" }
      end
    end

    describe "#comment" do
      describe "when have nothing" do
        let(:branch) { CurrentBranchMock.new nil }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new }

        it { subject.send(:comment).must_equal "Sorry, i forgot my task number. Ask me personally if you have any questions" }
      end

      describe "when have only branch name" do
        let(:branch) { CurrentBranchMock.new "hello" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new }

        it { subject.send(:comment).must_equal "http://jira.dev.apress.ru/browse/hello" }
      end

      describe "when have only option comment" do
        let(:branch) { CurrentBranchMock.new nil }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new({comment: "megusta"}) }

        it { subject.send(:comment).must_equal "megusta" }
      end

      describe "when have option comment and branch name" do
        let(:branch) { CurrentBranchMock.new "tako" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new({comment: "burito"}) }

        it { subject.send(:comment).must_equal "http://jira.dev.apress.ru/browse/tako\n\nburito" }
      end
    end

    describe "#branch" do
      describe "when have only option branch" do
        subject { Abak::Flow::PullRequest.new({branch: "tako"}) }

        it { subject.send(:branch).must_equal "tako" }
      end

      describe "when have only feature branch" do
        let(:branch) { CurrentBranchMock.new "tako", "feature" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new }

        it { subject.send(:branch).must_equal "develop" }
      end

      describe "when have only hotfix branch" do
        let(:branch) { CurrentBranchMock.new "tako", "hotfix" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new }

        it { subject.send(:branch).must_equal "master" }
      end

      describe "when have hotfix branch and option branch" do
        let(:branch) { CurrentBranchMock.new "tako", "hotfix" }
        before { Abak::Flow::PullRequest::Branches.current_branch = branch }

        subject { Abak::Flow::PullRequest.new({branch: "pewpew"}) }

        it { subject.send(:branch).must_equal "pewpew" }
      end
    end
  end

  describe "Publishing process" do
    subject { Abak::Flow::PullRequest.new }

    describe "when something goes wrong" do
      describe "when system is not ready" do
        before { Abak::Flow::PullRequest::System.ready = false }

        it { subject.publish.must_equal false }

        it "should store exception" do
          subject.stub(:invalid?, true) do
            subject.publish
            subject.exception.wont_be_nil
          end
        end
      end

      describe "when pull request is invalid" do
        before { Abak::Flow::PullRequest::System.ready = true }

        it "should be false" do
          subject.stub(:invalid?, true) do
            subject.publish.must_equal false
          end
        end
      end

      describe "when something raise exception" do
        before { Abak::Flow::PullRequest::System.ready = true }

        it "should not raise exception" do
          raise_object = NObject.new
          raise_object.instance_eval { def _links; raise Exception end }

          subject.stub(:invalid?, false) do
            subject.stub(:publish_pull_request, raise_object) do
              -> { subject.publish }.must_be_silent
            end
          end
        end

        it "should store exception" do
          raise_object = NObject.new
          raise_object.instance_eval { def _links; raise Exception end }

          subject.stub(:invalid?, false) do
            subject.stub(:publish_pull_request, raise_object) do
              subject.publish
              subject.exception.wont_be_nil
            end
          end
        end
      end
    end

    describe "when all right" do
      before { Abak::Flow::PullRequest::System.ready = true }

      it "shoud return true" do
        subject.stub(:requirements_satisfied?, true) do
          subject.stub(:publish_pull_request, NObject.new) do
            subject.publish.must_equal true
          end
        end
      end
    end

    describe "when use bang! method" do
      describe "when something goes wrong" do
        describe "when we raise exception" do
          before { Abak::Flow::PullRequest::System.ready = false }

          it { -> { subject.publish! }.must_raise Exception }
        end

        describe "when something raise exception" do
          before { Abak::Flow::PullRequest::System.ready = true }

          it "should raise exception" do
            raise_object = NObject.new
            raise_object.instance_eval { def _links; raise Exception end }

            subject.stub(:invalid?, false) do
              subject.stub(:publish_pull_request, raise_object) do
                -> { subject.publish! }.must_raise Exception
              end
            end
          end
        end
      end

      describe "when all right" do
        before { Abak::Flow::PullRequest::System.ready = true }

        it "shoud not raise Exception" do
          subject.stub(:requirements_satisfied?, true) do
            subject.stub(:publish_pull_request, NObject.new) do
              -> { subject.publish! }.must_be_silent
            end
          end
        end
      end
    end

    describe "#github_link" do
      describe "when request not published" do
        it { subject.github_link.must_be_nil }
      end

      describe "when request successfully published" do
        before { Abak::Flow::PullRequest::System.ready = true }

        it "shoud set github link" do
          subject.stub(:requirements_satisfied?, true) do
            subject.stub(:publish_pull_request, NObject.new({href: "wow"})) do
              subject.publish
              subject.github_link.must_equal "wow"
            end
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
        describe "when title not specified" do
          let(:branch) { CurrentBranchMock.new(nil, "hotfix") }
          before { Abak::Flow::PullRequest::Branches.current_branch = branch }

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

        describe "when branch not specified" do
          let(:branch) { CurrentBranchMock.new("SG-001", "pewpew") }
          before { Abak::Flow::PullRequest::Branches.current_branch = branch }

          it "should not satisfy requirements" do
            subject.send(:requirements_satisfied?).must_equal false
          end

          it "should have recommendations" do
            subject.stub(:specify_branch_recommendation, "unbelievable") do
              subject.valid?
              subject.recommendations.must_equal %w[unbelievable]
            end
          end
        end

        describe "when branch and title not specified" do
          let(:branch) { CurrentBranchMock.new(nil, "pewpew") }
          before { Abak::Flow::PullRequest::Branches.current_branch = branch }

          it "should not satisfy requirements" do
            subject.send(:requirements_satisfied?).must_equal false
          end

          it "should have recommendations" do
            subject.stub(:specify_title_recommendation, "that's") do
              subject.stub(:specify_branch_recommendation, "unbelievable") do
                subject.valid?
                subject.recommendations.must_equal %w[that's unbelievable]
              end
            end
          end
        end
      end
    end
  end
end