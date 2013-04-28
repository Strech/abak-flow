# coding: utf-8
require "spec_helper"

describe Abak::Flow::PullRequest do
  describe "Interface" do
    subject { described_class.new }

    it { should respond_to :valid? }
    it { should respond_to :invalid? }
    it { should respond_to :publish }
    it { should respond_to :publish! }

    it { should respond_to :recommendations }
    it { should respond_to :github_link }
    it { should respond_to :exception }
  end

  describe "Initialize process" do
    let(:attributes) { {target: "develop", title: "Fix some problem", body: "Check this request"} }
    let(:request) { described_class.new attributes }

    before do
      Abak::Flow::System.any_instance.stub(:ready).and_return true
      Abak::Flow::System.any_instance.stub(:recommendations).and_return []
    end

    subject { request }
    its(:options) { should_not be_nil }

    describe "#recommendations" do
      subject { request.recommendations }

      its(:first) { should be_empty }
      its(:last) { should be_empty }
    end
  end

  describe "#title" do
    before { Abak::Flow::Branches.stub(:current_branch).and_return branch }

    context "when have only branch name" do
      let(:branch) { double("Branch", tracker_task: "hello")  }
      subject { described_class.new }

      its(:title) { should eq "hello" }
    end

    context "when have only option task" do
      let(:branch) { double("Branch", tracker_task: nil)  }
      subject { described_class.new(title: "megusta") }

      its(:title) { should eq "megusta" }
    end

    context "when have option task and branch name" do
      let(:branch) { double("Branch", tracker_task: "tako")  }
      subject { described_class.new(title: "burito") }

      its(:title) { should eq "tako :: burito" }
    end
  end

  describe "#comment" do
    before { Abak::Flow::Branches.stub(:current_branch).and_return branch }

    describe "when have nothing" do
      let(:branch) { double("Branch", tracker_task: nil, task?: false)  }

      before { Abak::Flow::Messages.any_instance.should_receive(:t).with(:forgot_task).and_return "I forgot my task" }
      subject { described_class.new }

      its(:comment) { should eq "I forgot my task" }
    end

    describe "when have only branch name" do
      let(:branch) { double("Branch", tracker_task: "hello", task?: true)  }

      before { described_class.any_instance.stub(:default_comment).and_return "Default comment" }
      subject { described_class.new }

      its(:comment) { should eq "Default comment" }
    end

    describe "when have only option comment" do
      let(:branch) { double("Branch", tracker_task: "hello", task?: false)  }

      subject { described_class.new(comment: "megusta") }

      its(:comment) { should eq "megusta" }
    end

    describe "when have option comment and branch name" do
      let(:branch) { double("Branch", tracker_task: "tako", task?: true)  }

      before { described_class.any_instance.stub(:default_comment).and_return "Default comment" }
      subject { described_class.new(comment: "burito") }

      its(:comment) { should include "Default comment" }
      its(:comment) { should include "burito" }
    end
  end

  describe "#branch" do
    before { Abak::Flow::Branches.stub(:current_branch).and_return branch }

    describe "when have only option branch" do
      let(:branch) { double("Branch", tracker_task: nil) }
      subject { described_class.new(branch: "tako") }

      its(:branch) { should eq "tako" }
    end

    describe "when have only feature branch" do
      let(:branch) { double("Branch", tracker_task: "tako", hotfix?: false, feature?: true) }

      subject { described_class.new }

      its(:branch) { should eq "develop" }
    end

    describe "when have only hotfix branch" do
      let(:branch) { double("Branch", tracker_task: "tako", feature?: false, hotfix?: true) }

      subject { described_class.new }

      its(:branch) { should eq "master" }
    end

    describe "when have hotfix branch and option branch" do
      let(:branch) { double("Branch", tracker_task: "tako", feature?: false, hotfix?: true) }

      subject { described_class.new(branch: "pewpew") }

      its(:branch) { should eq "pewpew" }
    end
  end


  # describe "Publishing process" do
  #   subject { Abak::Flow::PullRequest.new }
  #
  #   describe "when something goes wrong" do
  #     describe "when system is not ready" do
  #       before { Abak::Flow::PullRequest::System.ready = false }
  #
  #       it { subject.publish.must_equal false }
  #
  #       it "should store exception" do
  #         subject.stub(:invalid?, true) do
  #           subject.publish
  #           subject.exception.wont_be_nil
  #         end
  #       end
  #     end
  #
  #     describe "when pull request is invalid" do
  #       before { Abak::Flow::PullRequest::System.ready = true }
  #
  #       it "should be false" do
  #         subject.stub(:invalid?, true) do
  #           subject.publish.must_equal false
  #         end
  #       end
  #     end
  #
  #     describe "when something raise exception" do
  #       before { Abak::Flow::PullRequest::System.ready = true }
  #
  #       it "should not raise exception" do
  #         raise_object = NObject.new
  #         raise_object.instance_eval { def _links; raise Exception end }
  #
  #         subject.stub(:invalid?, false) do
  #           subject.stub(:publish_pull_request, raise_object) do
  #             -> { subject.publish }.must_be_silent
  #           end
  #         end
  #       end
  #
  #       it "should store exception" do
  #         raise_object = NObject.new
  #         raise_object.instance_eval { def _links; raise Exception end }
  #
  #         subject.stub(:invalid?, false) do
  #           subject.stub(:publish_pull_request, raise_object) do
  #             subject.publish
  #             subject.exception.wont_be_nil
  #           end
  #         end
  #       end
  #     end
  #   end
  #
  #   describe "when all right" do
  #     before { Abak::Flow::PullRequest::System.ready = true }
  #
  #     it "shoud return true" do
  #       subject.stub(:requirements_satisfied?, true) do
  #         subject.stub(:publish_pull_request, NObject.new) do
  #           subject.publish.must_equal true
  #         end
  #       end
  #     end
  #   end
  #
  #   describe "when use bang! method" do
  #     describe "when something goes wrong" do
  #       describe "when we raise exception" do
  #         before { Abak::Flow::PullRequest::System.ready = false }
  #
  #         it { -> { subject.publish! }.must_raise Exception }
  #       end
  #
  #       describe "when something raise exception" do
  #         before { Abak::Flow::PullRequest::System.ready = true }
  #
  #         it "should raise exception" do
  #           raise_object = NObject.new
  #           raise_object.instance_eval { def _links; raise Exception end }
  #
  #           subject.stub(:invalid?, false) do
  #             subject.stub(:publish_pull_request, raise_object) do
  #               -> { subject.publish! }.must_raise Exception
  #             end
  #           end
  #         end
  #       end
  #     end
  #
  #     describe "when all right" do
  #       before { Abak::Flow::PullRequest::System.ready = true }
  #
  #       it "shoud not raise Exception" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.stub(:publish_pull_request, NObject.new) do
  #             -> { subject.publish! }.must_be_silent
  #           end
  #         end
  #       end
  #     end
  #   end
  #
  #   describe "#github_link" do
  #     describe "when request not published" do
  #       it { subject.github_link.must_be_nil }
  #     end
  #
  #     describe "when request successfully published" do
  #       before { Abak::Flow::PullRequest::System.ready = true }
  #
  #       it "shoud set github link" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.stub(:publish_pull_request, NObject.new({href: "wow"})) do
  #             subject.publish
  #             subject.github_link.must_equal "wow"
  #           end
  #         end
  #       end
  #     end
  #   end
  # end
  #
  # describe "Validation process" do
  #   describe "when system is not ready" do
  #     before do
  #       Abak::Flow::PullRequest::System.ready = false
  #       Abak::Flow::PullRequest::System.recommendations = %w[one two three]
  #     end
  #
  #     subject { Abak::Flow::PullRequest.new }
  #
  #     describe "when pull request is valid" do
  #       it "should not be valid pull request" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.valid?.must_equal false
  #         end
  #       end
  #
  #       it "should be invalid request" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.invalid?.must_equal true
  #         end
  #       end
  #
  #       it "should have system recommendations" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.valid?
  #           subject.recommendations[0].wont_be_empty
  #         end
  #       end
  #     end
  #
  #     describe "when pull request is invalid" do
  #       it "should have only system recommendations" do
  #         subject.stub(:requirements_satisfied?, false) do
  #           subject.valid?
  #           subject.recommendations[0].wont_be_empty
  #           subject.recommendations[1].must_be_empty
  #         end
  #       end
  #     end
  #   end
  #
  #   describe "when system is ready" do
  #     before do
  #       Abak::Flow::PullRequest::System.ready = true
  #       Abak::Flow::PullRequest::System.recommendations = []
  #     end
  #
  #     subject { Abak::Flow::PullRequest.new }
  #
  #     describe "when pull request is valid" do
  #       it "should be valid pull request" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.valid?.must_equal true
  #         end
  #       end
  #
  #       it "should not be invalid request" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.invalid?.must_equal false
  #         end
  #       end
  #
  #       it "should not have system recommendations" do
  #         subject.stub(:requirements_satisfied?, true) do
  #           subject.valid?
  #           subject.recommendations[0].must_be_empty
  #         end
  #       end
  #     end
  #
  #     describe "when pull request is invalid" do
  #       describe "when title not specified" do
  #         let(:branch) { CurrentBranchMock.new(nil, "hotfix") }
  #         before { Abak::Flow::PullRequest::Branches.current_branch = branch }
  #
  #         it "should not satisfy requirements" do
  #           subject.send(:requirements_satisfied?).must_equal false
  #         end
  #
  #         it "should have recommendations" do
  #           subject.valid?
  #           subject.recommendations[1].wont_be_empty
  #         end
  #       end
  #
  #       describe "when branch not specified" do
  #         let(:branch) { CurrentBranchMock.new("SG-001", "pewpew") }
  #         before { Abak::Flow::PullRequest::Branches.current_branch = branch }
  #
  #         it "should not satisfy requirements" do
  #           subject.send(:requirements_satisfied?).must_equal false
  #         end
  #
  #         it "should have recommendations" do
  #           subject.valid?
  #           subject.recommendations[1].wont_be_empty
  #         end
  #       end
  #
  #       describe "when branch and title not specified" do
  #         let(:branch) { CurrentBranchMock.new(nil, "pewpew") }
  #         before { Abak::Flow::PullRequest::Branches.current_branch = branch }
  #
  #         it "should not satisfy requirements" do
  #           subject.send(:requirements_satisfied?).must_equal false
  #         end
  #
  #         it "should have recommendations" do
  #           subject.valid?
  #           subject.recommendations[1].wont_be_empty
  #         end
  #       end
  #     end
  #   end
  # end
end