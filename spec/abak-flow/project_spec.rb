# coding: utf-8
require "spec_helper"
require "abak-flow/project"

describe Abak::Flow::Project do
  let(:origin) do
    RemoteMock.new "origin", "git@github.com:Strech/abak-flow.git"
  end

  let(:upstream) do
    RemoteMock.new "upstream", "http://github.com/Godlike/abak-flow-new.git"
  end

  let(:git) { GitMock.new [origin, upstream] }
  let(:described_class) { Abak::Flow::Project }

  describe "when init project" do
    it { described_class.must_respond_to :init }
    it { described_class.must_respond_to :remotes }

    it "should create method origin" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.must_respond_to :origin
      end
    end

    it "should create method upstream" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.must_respond_to :upstream
      end
    end

    it "should return nil on incorrect url" do
      remote = RemoteMock.new "wrong", "git@wrong-site.com:Me/wrong-flow.git"

      described_class.send(:create_github_remote, remote).must_be_nil
    end

    it "should raise Exception when check requirements" do
      remote = RemoteMock.new "wrong", "git@wrong-site.com:Me/wrong-flow.git"

      described_class.stub(:init_remotes, nil) do
        described_class.stub(:remotes, [remote]) do
          described_class.init
          -> { described_class.check_requirements }.must_raise Exception
        end
      end
    end
  end

  describe "when ask for owner and project" do
    it "should have origin owner as Strech" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.origin.owner.must_equal "Strech"
      end
    end

    it "should have origin project as abak-flow" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.origin.project.must_equal "abak-flow"
      end
    end

    it "should have upstream owner as Godlike" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.upstream.owner.must_equal "Godlike"
      end
    end

    it "should have upstream project as abak-flow-new" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.upstream.project.must_equal "abak-flow-new"
      end
    end
  end

  describe "Remote" do
    it "should respond #to_s" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.upstream.must_respond_to :to_s
      end
    end

    it "should return owner/project" do
      described_class.stub(:git, git) do
        described_class.init
        described_class.upstream.to_s.must_equal "Godlike/abak-flow-new"
      end
    end
  end
end