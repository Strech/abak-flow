# coding: utf-8
require "spec_helper"
require "abak-flow/branches"

describe Abak::Flow::Branches do
  class GitMock < Struct.new(:branches, :current_branch); end
  class BranchMock < Struct.new(:full); end
  
  let(:described_class) { Abak::Flow::Branches }
  let(:develop) { BranchMock.new "develop" }
  let(:master) { BranchMock.new "master" }
  let(:hotfix) { BranchMock.new "hotfix/PR-2011" }
  let(:feature) { BranchMock.new "feature/JP-515" }
  let(:noname) { BranchMock.new "my_own/branch_name" }
  
  describe "Interface" do
    it "should respond to current_branch" do
      described_class.must_respond_to :current_branch
    end
  end
  
  describe "#current_branch" do
    let(:git) { GitMock.new({"hotfix/PR-2011" => hotfix}, "hotfix/PR-2011") }
    
    it "should return new wrapped Branch" do
      described_class.stub(:git, git) do
        described_class.current_branch.must_be_kind_of Abak::Flow::Branches::Branch
      end
    end
  end

  describe Abak::Flow::Branches::Branch do
    let(:described_class) { Abak::Flow::Branches::Branch }
    let(:described_instance) { Abak::Flow::Branches::Branch.new nil }
    
    describe "Interface" do
      it "should respond to name" do
        described_instance.must_respond_to :name
      end
    
      it "should respond to prefix" do
        described_instance.must_respond_to :prefix
      end
      
      it "should respond to task" do
        described_instance.must_respond_to :task
      end
    end
    
    describe "#name" do
      it "should return full name from complex branch" do
        described_class.new(feature).name.must_equal "feature/JP-515"
      end
      
      it "should return full name from simple branch name" do
        described_class.new(develop).name.must_equal "develop"
      end
    end
    
    describe "#prefix" do
    end
    
    describe "#task" do
    end
    
    describe "#hotfix?" do
    end

    describe "#feature?" do
    end
  end
end