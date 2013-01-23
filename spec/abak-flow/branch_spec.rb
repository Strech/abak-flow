# coding: utf-8
require "spec_helper"
require "abak-flow/branch"

describe Abak::Flow::Branch do
  let(:described_class) { Abak::Flow::Branch }
  let(:develop) { BranchMock.new "develop" }
  let(:master) { BranchMock.new "master" }
  let(:hotfix) { BranchMock.new "hotfix/PR-2011" }
  let(:feature) { BranchMock.new "feature/JP-515" }
  let(:noname) { BranchMock.new "my_own/what_i_want/branch_name" }
    
  describe "#name" do
    it "should return full name from complex branch" do
      described_class.new(feature).name.must_equal "feature/JP-515"
    end
      
    it "should return full name from simple branch name" do
      described_class.new(develop).name.must_equal "develop"
    end
  end
    
  describe "#prefix" do
    it "should return nil for branch without prefix" do
      described_class.new(develop).prefix.must_be_nil
    end
      
    it "should return 'hotfix' for branch with hotfix-prefix" do
      described_class.new(hotfix).prefix.must_equal "hotfix"
    end
      
    it "should return 'feature' for branch with feature-prefix" do
      described_class.new(feature).prefix.must_equal "feature"
    end

    it "should return 'my_own/what_i_want' for branch with noname-prefix" do
      described_class.new(noname).prefix.must_equal "my_own/what_i_want"
    end
  end
    
  describe "#task" do
    it "should return nil for branch without task-postfix" do
      described_class.new(develop).task.must_be_nil
    end
      
    it "should return 'JP-515' for branch with task-postfix" do
      described_class.new(feature).task.must_equal "JP-515"
    end

    it "should return 'branch_name' for branch with noname-postfix" do
      described_class.new(noname).task.must_equal "branch_name"
    end
  end
    
  describe "#hotfix?" do
    it "should return false for branch without prefix" do
      described_class.new(develop).hotfix?.must_equal false
    end
      
    it "should return false for branch with noname-prefix" do
      described_class.new(noname).hotfix?.must_equal false
    end
      
    it "should return false for branch with feature-prefix" do
      described_class.new(feature).hotfix?.must_equal false
    end

    it "should return true for branch with hotfix-prefix" do
      described_class.new(hotfix).hotfix?.must_equal true
    end
  end

  describe "#feature?" do
    it "should return false for branch without prefix" do
      described_class.new(master).feature?.must_equal false
    end
      
    it "should return false for branch with noname-prefix" do
      described_class.new(noname).feature?.must_equal false
    end
      
    it "should return false for branch with hotfix-prefix" do
      described_class.new(hotfix).feature?.must_equal false
    end

    it "should return true for branch with feature-prefix" do
      described_class.new(feature).feature?.must_equal true
    end
  end
    
  describe "#task?" do
    it "should return false for branch without task" do
      described_class.new(develop).task?.must_equal false
    end
      
    it "should return false for branch with noname-task" do
      described_class.new(noname).task?.must_equal false
    end
      
    it "should return true for branch with hotfix-prefix and task-postfix" do
      described_class.new(hotfix).task?.must_equal true
    end

    it "should return true for branch with feature-prefix and task-postfix" do
      described_class.new(feature).task?.must_equal true
    end
  end
    
end