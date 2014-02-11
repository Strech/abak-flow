# coding: utf-8
require "spec_helper"

describe Abak::Flow::Branch do
  let(:develop) { double("Branch", name: "develop", full: "develop") }
  let(:master) { double("Branch", name: "master", full: "master") }
  let(:hotfix) { double("Branch", name: "hotfix/PR-2011", full: "hotfix/PR-2011") }
  let(:feature) { double("Branch", name: "feature/JP-515", full: "feature/JP-515") }
  let(:noname) { double("Branch", name: "my/own/name", full: "my/own/name") }

  let(:manager) { double("Manager", git: git) }
  let(:git) { double("Git") }

  before do
    Abak::Flow::Manager.stub(:instance).and_return manager

    git.stub(:branch) { |x| x }
  end

  describe "#name" do
    it { expect(described_class.new(feature).name).to eq "feature/JP-515" }
    it { expect(described_class.new(develop).name).to eq "develop" }
  end

  describe "#folder" do
    it { expect(described_class.new(develop).folder).to be_nil }
    it { expect(described_class.new(hotfix).folder).to eq "hotfix" }
    it { expect(described_class.new(feature).folder).to eq "feature" }
    it { expect(described_class.new(noname).folder).to eq "my/own" }
  end

  describe "#task" do
    it { expect(described_class.new(develop).task).to be_nil }
    it { expect(described_class.new(feature).task).to eq "JP-515" }
    it { expect(described_class.new(noname).task).to eq "name" }
  end

  describe "#hotfix?" do
    it { expect(described_class.new(develop).hotfix?).to be_false }
    it { expect(described_class.new(noname).hotfix?).to be_false }
    it { expect(described_class.new(feature).hotfix?).to be_false }
    it { expect(described_class.new(hotfix).hotfix?).to be_true }
  end

  describe "#feature?" do
    it { expect(described_class.new(master).feature?).to be_false }
    it { expect(described_class.new(noname).feature?).to be_false }
    it { expect(described_class.new(hotfix).feature?).to be_false }
    it { expect(described_class.new(feature).feature?).to be_true }
  end

  describe "#master?" do
    it { expect(described_class.new(master).master?).to be_true }
    it { expect(described_class.new(noname).master?).to be_false }
    it { expect(described_class.new(develop).master?).to be_false }
  end

  describe "#develop?" do
    it { expect(described_class.new(develop).develop?).to be_true }
    it { expect(described_class.new(noname).develop?).to be_false }
    it { expect(described_class.new(master).develop?).to be_false }
  end

  describe "#tracker_task?" do
    it { expect(described_class.new(develop).tracker_task?).to be_false }
    it { expect(described_class.new(noname).tracker_task?).to be_false }
    it { expect(described_class.new(hotfix).tracker_task?).to be_true }
    it { expect(described_class.new(feature).tracker_task?).to be_true }
  end

  describe "#mappable?" do
    it { expect(described_class.new(develop).mappable?).to be_false }
    it { expect(described_class.new(noname).mappable?).to be_false }
    it { expect(described_class.new(hotfix).mappable?).to be_true }
    it { expect(described_class.new(feature).mappable?).to be_true }
  end

  describe "#valid?" do
    it { expect(described_class.new(develop).valid?).to be_true }
    it { expect(described_class.new(noname).valid?).to be_true }
    it do
      branch = double("Branch", name: "", full: "", is_a?: true)
      expect(described_class.new(branch).valid?).to be_false
    end
  end

  describe "#current?" do
    before do
      develop.stub(:current).and_return true
      master.stub(:current).and_return false
    end

    it { expect(described_class.new(develop).current?).to be_true }
    it { expect(described_class.new(master).current?).to be_false }
  end

  describe "#to_s" do
    before { develop.stub(:to_s).and_return "Yap!" }
    it { expect(described_class.new(develop).to_s).to eq "Yap!" }
  end

  describe "#message" do
    before { noname.stub(:gcommit).and_return gcommit }

    context "when git commit is a short single line" do
      let(:gcommit) { double("Git commit", message: "Hello commit message") }

      it { expect(described_class.new(noname).message).to eq "Hello commit message" }
    end

    context "when git commit is a very long single line" do
      let(:gcommit) { double("Git commit", message: "X" * 200) }

      it { expect(described_class.new(noname).message.length).to eq 75 }
      it { expect(described_class.new(noname).message).to include "..." }
    end

    context "when git commit is a short multi line" do
      let(:message) { "Hello commit message\n\nFixes PC4-100" }
      let(:gcommit) { double("Git commit", message: message) }

      it { expect(described_class.new(noname).message).to eq "Hello commit message" }
    end

    context "when git commit is a very long multi line" do
      let(:message) { "#{'X' * 200}\n\nFixes PC4-100" }
      let(:gcommit) { double("Git commit", message: message) }

      it { expect(described_class.new(noname).message.length).to eq 75 }
      it { expect(described_class.new(noname).message).to include "..." }
    end
  end
end
