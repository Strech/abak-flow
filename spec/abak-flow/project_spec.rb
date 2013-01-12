# coding: utf-8
require "spec_helper"
require "abak-flow/project"

describe Abak::Flow::Project do
  let(:origin) do
    repo = MiniTest::Mock.new
    repo.expect :name, "origin"
    repo.expect :url, "git@github.com:Strech/abak-flow.git"

    repo
  end

  let(:upstream) do
    repo = MiniTest::Mock.new
    repo.expect :name, "upstream"
    repo.expect :url, "git@github.com:Godlike/abak-flow-new.git"

    repo
  end

  let(:git) do
    git = MiniTest::Mock.new
    git.expect :remotes, [origin, upstream]
  end

  let(:described_class) { Abak::Flow::Project }

  describe "when init project" do
    it "should respond to init" do
      described_class.must_respond_to :init
    end

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

    it "should raise Exception while init" do
      repo = MiniTest::Mock.new
      repo.expect :name, "wrong"
      repo.expect :url, "git@wrong-site.com:Me/wrong-flow.git"

      git = MiniTest::Mock.new
      git.expect :remotes, [repo]

      described_class.stub(:git, git) do
        -> { described_class.init }.must_raise Exception
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