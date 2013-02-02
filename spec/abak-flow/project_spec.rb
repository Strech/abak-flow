# coding: utf-8
require "spec_helper"
require "abak-flow/project"

describe Abak::Flow::Project do
  subject { Abak::Flow::Project }

  let(:origin) do
    RemoteMock.new "origin", "git@github.com:Strech/abak-flow.git"
  end

  let(:upstream) do
    RemoteMock.new "upstream", "http://github.com/Godlike/abak-flow-new.git"
  end

  let(:git) { GitMock.new [origin, upstream] }

  describe "when init project" do
    it { subject.must_respond_to :init }
    it { subject.must_respond_to :remotes }

    it "should create method origin" do
      subject.stub(:git, git) do
        subject.init
        subject.must_respond_to :origin
      end
    end

    it "should create method upstream" do
      subject.stub(:git, git) do
        subject.init
        subject.must_respond_to :upstream
      end
    end

    it "should return nil on incorrect url" do
      remote = RemoteMock.new "wrong", "git@wrong-site.com:Me/wrong-flow.git"

      subject.send(:create_github_remote, remote).must_be_nil
    end

    it "should raise Exception when check requirements" do
      remote = RemoteMock.new "wrong", "git@wrong-site.com:Me/wrong-flow.git"

      subject.stub(:init_remotes, nil) do
        subject.stub(:remotes, [remote]) do
          subject.init
          -> { subject.check_requirements }.must_raise Exception
        end
      end
    end
  end

  describe "when ask for owner and project" do
    it "should have origin owner as Strech" do
      subject.stub(:git, git) do
        subject.init
        subject.origin.owner.must_equal "Strech"
      end
    end

    it "should have origin project as abak-flow" do
      subject.stub(:git, git) do
        subject.init
        subject.origin.project.must_equal "abak-flow"
      end
    end

    it "should have upstream owner as Godlike" do
      subject.stub(:git, git) do
        subject.init
        subject.upstream.owner.must_equal "Godlike"
      end
    end

    it "should have upstream project as abak-flow-new" do
      subject.stub(:git, git) do
        subject.init
        subject.upstream.project.must_equal "abak-flow-new"
      end
    end
  end

  describe "Remote" do
    it "should respond #to_s" do
      subject.stub(:git, git) do
        subject.init
        subject.upstream.must_respond_to :to_s
      end
    end

    it "should return owner/project" do
      subject.stub(:git, git) do
        subject.init
        subject.upstream.to_s.must_equal "Godlike/abak-flow-new"
      end
    end
  end
end