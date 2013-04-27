# coding: utf-8
require "spec_helper"

describe Abak::Flow::Branch do
  let(:develop) { double("Branch", full: "develop") }
  let(:master) { double("Branch", full: "master") }
  let(:hotfix) { double("Branch", full: "hotfix/PR-2011") }
  let(:feature) { double("Branch", full: "feature/JP-515") }
  let(:noname) { double("Branch", full: "my_own/what_i_want/branch_name") }

  describe "#name" do
    it { described_class.new(feature).name.should eq "feature/JP-515" }
    it { described_class.new(develop).name.should eq "develop" }
  end

  describe "#prefix" do
    it { described_class.new(develop).prefix.should be_nil }
    it { described_class.new(hotfix).prefix.should eq "hotfix" }
    it { described_class.new(feature).prefix.should eq "feature" }
    it { described_class.new(noname).prefix.should eq "my_own/what_i_want" }
  end

  describe "#task" do
    it { described_class.new(develop).task.should be_nil }
    it { described_class.new(feature).task.should eq "JP-515" }
    it { described_class.new(noname).task.should eq "branch_name" }
  end

  describe "#hotfix?" do
    it { described_class.new(develop).hotfix?.should eq false }
    it { described_class.new(noname).hotfix?.should eq false }
    it { described_class.new(feature).hotfix?.should eq false }
    it { described_class.new(hotfix).hotfix?.should eq true }
  end

  describe "#feature?" do
    it { described_class.new(master).feature?.should eq false }
    it { described_class.new(noname).feature?.should eq false }
    it { described_class.new(hotfix).feature?.should eq false }
    it { described_class.new(feature).feature?.should eq true }
  end

  describe "#task?" do
    it { described_class.new(develop).task?.should eq false }
    it { described_class.new(noname).task?.should eq false }
    it { described_class.new(hotfix).task?.should eq true }
    it { described_class.new(feature).task?.should eq true }
  end

  describe "#tracker_task" do
    it { described_class.new(develop).tracker_task.should be_nil }
    it { described_class.new(feature).tracker_task.should eq "JP-515" }
    it { described_class.new(noname).tracker_task.should be_nil }
  end
end