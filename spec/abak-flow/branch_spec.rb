# coding: utf-8
require "spec_helper"
require "abak-flow/branch"

describe Abak::Flow::Branch do
  subject { Abak::Flow::Branch }

  let(:develop) { BranchMock.new "develop" }
  let(:master) { BranchMock.new "master" }
  let(:hotfix) { BranchMock.new "hotfix/PR-2011" }
  let(:feature) { BranchMock.new "feature/JP-515" }
  let(:noname) { BranchMock.new "my_own/what_i_want/branch_name" }

  describe "#name" do
    it { subject.new(feature).name.must_equal "feature/JP-515" }
    it { subject.new(develop).name.must_equal "develop" }
  end

  describe "#prefix" do
    it { subject.new(develop).prefix.must_be_nil }
    it { subject.new(hotfix).prefix.must_equal "hotfix" }
    it { subject.new(feature).prefix.must_equal "feature" }
    it { subject.new(noname).prefix.must_equal "my_own/what_i_want" }
  end

  describe "#task" do
    it { subject.new(develop).task.must_be_nil }
    it { subject.new(feature).task.must_equal "JP-515" }
    it { subject.new(noname).task.must_equal "branch_name" }
  end

  describe "#hotfix?" do
    it { subject.new(develop).hotfix?.must_equal false }
    it { subject.new(noname).hotfix?.must_equal false }
    it { subject.new(feature).hotfix?.must_equal false }
    it { subject.new(hotfix).hotfix?.must_equal true }
  end

  describe "#feature?" do
    it { subject.new(master).feature?.must_equal false }
    it { subject.new(noname).feature?.must_equal false }
    it { subject.new(hotfix).feature?.must_equal false }
    it { subject.new(feature).feature?.must_equal true }
  end

  describe "#task?" do
    it { subject.new(develop).task?.must_equal false }
    it { subject.new(noname).task?.must_equal false }
    it { subject.new(hotfix).task?.must_equal true }
    it { subject.new(feature).task?.must_equal true }
  end

end