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
    it { described_class.new(feature).name.must_equal "feature/JP-515" }
    it { described_class.new(develop).name.must_equal "develop" }
  end
    
  describe "#prefix" do
    it { described_class.new(develop).prefix.must_be_nil }
    it { described_class.new(hotfix).prefix.must_equal "hotfix" }
    it { described_class.new(feature).prefix.must_equal "feature" }
    it { described_class.new(noname).prefix.must_equal "my_own/what_i_want" }
  end
    
  describe "#task" do
    it { described_class.new(develop).task.must_be_nil }
    it { described_class.new(feature).task.must_equal "JP-515" }
    it { described_class.new(noname).task.must_equal "branch_name" }
  end
    
  describe "#hotfix?" do
    it { described_class.new(develop).hotfix?.must_equal false }
    it { described_class.new(noname).hotfix?.must_equal false }
    it { described_class.new(feature).hotfix?.must_equal false }
    it { described_class.new(hotfix).hotfix?.must_equal true }
  end

  describe "#feature?" do
    it { described_class.new(master).feature?.must_equal false }
    it { described_class.new(noname).feature?.must_equal false }
    it { described_class.new(hotfix).feature?.must_equal false }
    it { described_class.new(feature).feature?.must_equal true }
  end
    
  describe "#task?" do
    it { described_class.new(develop).task?.must_equal false }
    it { described_class.new(noname).task?.must_equal false }
    it { described_class.new(hotfix).task?.must_equal true }
    it { described_class.new(feature).task?.must_equal true }
  end
    
end