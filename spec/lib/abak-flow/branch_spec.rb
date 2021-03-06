# coding: utf-8
require "spec_helper"

describe Abak::Flow::Branch do
  let(:git_develop) { double("Develop", name: "develop", full: "develop") }
  let(:git_master) { double("Master", name: "master", full: "master") }
  let(:git_hotfix) { double("Hotfix", name: "hotfix/PR-2011", full: "hotfix/PR-2011") }
  let(:git_feature) { double("Feature", name: "feature/JP-515", full: "feature/JP-515") }
  let(:git_noname) { double("Noname", name: "my/own/name", full: "my/own/name") }

  let(:develop) { described_class.new git_develop }
  let(:master) { described_class.new git_master }
  let(:hotfix) { described_class.new git_hotfix }
  let(:feature) { described_class.new git_feature }
  let(:noname) { described_class.new git_noname }

  let(:manager) { double("Manager", git: git) }
  let(:git) { double("Git") }

  before do
    Abak::Flow::Manager.stub(:instance).and_return manager

    git.stub(:branch) { |x| x }
  end

  describe "#name" do
    it { expect(feature.name).to eq "feature/JP-515" }
    it { expect(develop.name).to eq "develop" }
    it { expect(noname.name).to eq "my/own/name" }
  end

  describe "#folder" do
    it { expect(develop.folder).to be_nil }
    it { expect(hotfix.folder).to eq "hotfix" }
    it { expect(feature.folder).to eq "feature" }
    it { expect(noname.folder).to eq "my/own" }
  end

  describe "#task" do
    it { expect(develop.task).to be_nil }
    it { expect(feature.task).to eq "JP-515" }
    it { expect(noname.task).to eq "name" }
  end

  describe "#hotfix?" do
    it { expect(develop.hotfix?).to be_false }
    it { expect(noname.hotfix?).to be_false }
    it { expect(feature.hotfix?).to be_false }
    it { expect(hotfix.hotfix?).to be_true }
  end

  describe "#feature?" do
    it { expect(master.feature?).to be_false }
    it { expect(noname.feature?).to be_false }
    it { expect(hotfix.feature?).to be_false }
    it { expect(feature.feature?).to be_true }
  end

  describe "#master?" do
    it { expect(master.master?).to be_true }
    it { expect(noname.master?).to be_false }
    it { expect(develop.master?).to be_false }
  end

  describe "#develop?" do
    it { expect(develop.develop?).to be_true }
    it { expect(noname.develop?).to be_false }
    it { expect(master.develop?).to be_false }
  end

  describe "#tracker_task?" do
    it { expect(develop.tracker_task?).to be_false }
    it { expect(noname.tracker_task?).to be_false }
    it { expect(hotfix.tracker_task?).to be_true }
    it { expect(feature.tracker_task?).to be_true }
  end

  describe "#mappable?" do
    it { expect(develop.mappable?).to be_false }
    it { expect(noname.mappable?).to be_false }
    it { expect(hotfix.mappable?).to be_true }
    it { expect(feature.mappable?).to be_true }
  end

  describe "#valid?" do
    it { expect(develop.valid?).to be_true }
    it { expect(noname.valid?).to be_true }
    it do
      branch = double("Branch", name: "", full: "")
      expect(described_class.new(branch).valid?).to be_false
    end
  end

  describe "#current?" do
    before do
      git_develop.stub(:current).and_return true
      git_master.stub(:current).and_return false
    end

    it { expect(develop.current?).to be_true }
    it { expect(master.current?).to be_false }
  end

  describe "#to_s" do
    before { git_develop.stub(:to_s).and_return "Yap!" }
    it { expect(develop.to_s).to eq "Yap!" }
  end

  describe "#message" do
    before { git_noname.stub(:gcommit).and_return gcommit }

    context "when git commit is a short single line" do
      let(:gcommit) { double("Git commit", message: "Hello commit message") }

      it { expect(noname.message).to eq "Hello commit message" }
    end

    context "when git commit is a very long single line" do
      let(:gcommit) { double("Git commit", message: "X" * 200) }

      it { expect(noname.message.length).to eq 75 }
      it { expect(noname.message).to include "..." }
    end

    context "when git commit is a short multi line" do
      let(:message) { "Hello commit message\n\nAnother new line" }
      let(:gcommit) { double("Git commit", message: message) }

      it { expect(noname.message).to eq "Hello commit message" }
    end

    context "when git commit is a very long multi line" do
      let(:message) { "#{'X' * 200}\n\nAnother new line" }
      let(:gcommit) { double("Git commit", message: message) }

      it { expect(noname.message.length).to eq 75 }
      it { expect(noname.message).to include "..." }
    end
  end

  describe "#extract_title" do
    let(:message) { "Hello world!\n\nAnother new line" }
    let(:gcommit) { double("Git commit", message: message) }

    context "when branch named not like tracker task" do
      before { git_noname.stub(:gcommit).and_return gcommit }

      it { expect(noname.extract_title).to eq "Hello world!" }
    end

    context "when branch named not like tracker task" do
      before { git_feature.stub(:gcommit).and_return gcommit }

      it { expect(feature.extract_title).to eq "JP-515" }
    end
  end

  describe "#extract_base_name" do
    context "when no options are given" do
      it { expect(master.extract_base_name).to eq "master" }
      it { expect(develop.extract_base_name).to eq "develop" }
      it { expect(hotfix.extract_base_name).to eq "master" }
      it { expect(feature.extract_base_name).to eq "develop" }
      it { expect(noname.extract_base_name).to eq "my/own/name" }
    end

    context "when if_undef option is given" do
      it { expect(hotfix.extract_base_name(if_undef: "foo")).to eq "master" }
      it { expect(master.extract_base_name(if_undef: "foo")).to eq "foo" }
      it { expect(noname.extract_base_name(if_undef: "foo")).to eq "foo" }
    end
  end

  describe "#extract_body" do
    before { I18n.stub(:t).with("abak.flow.commands.publish.words.nothing").and_return "Empty!" }

    context "when commit message has no magick words" do
      let(:gcommit) { double("Git commit", contents: "Hello world") }

      before do
        git_feature.stub(:gcommit).and_return gcommit
        git_hotfix.stub(:gcommit).and_return gcommit
        git_master.stub(:gcommit).and_return gcommit
        git_develop.stub(:gcommit).and_return gcommit
        git_noname.stub(:gcommit).and_return gcommit
      end

      it { expect(feature.extract_body).to eq "http://jira.railsc.ru/browse/JP-515" }
      it { expect(hotfix.extract_body).to eq "http://jira.railsc.ru/browse/PR-2011" }
      it { expect(master.extract_body).to eq "Empty!" }
      it { expect(develop.extract_body).to eq "Empty!" }
      it { expect(noname.extract_body).to eq "Empty!" }

      it  do
        branch = double("Branch", name: "feature/ho-ho-ho", full: "feature/ho-ho-ho")
        branch.stub(:gcommit).and_return gcommit

        expect(described_class.new(branch).extract_body).to eq "Empty!"
      end

      it do
        branch = double("Branch", name: "ho-ho-ho/PC4-10202", full: "ho-ho-ho/PC4-10202")
        branch.stub(:gcommit).and_return gcommit

        expect(described_class.new(branch).extract_body).to eq "http://jira.railsc.ru/browse/PC4-10202"
      end
    end

    context "when commit message has magick word" do
      context "when branch is task different from commit message" do
        let(:gcommit) { double("Git commit", contents: "Fix PC4-200") }

        before { git_feature.stub(:gcommit).and_return gcommit }

        it { expect(feature.extract_body).to eq "http://jira.railsc.ru/browse/PC4-200\nhttp://jira.railsc.ru/browse/JP-515" }
      end

      context "when branch is task equals to commit message" do
        let(:gcommit) { double("Git commit", contents: "[Fix JP-515]") }

        before { git_feature.stub(:gcommit).and_return gcommit }

        it { expect(feature.extract_body).to eq "http://jira.railsc.ru/browse/JP-515" }
      end

      context "when branch is not task" do
        let(:gcommit) do
          double("Git commit",
            contents: "tree 077f77484213cd706ec6958dc7836d1c8d6aafe6\nparent 266a68fec47942a53a119c78ce74994372107d44\nauthor Strech (Sergey Fedorov) <strech_ftf@mail.ru> 1393176082 +0600\ncommitter Strech (Sergey Fedorov) <strech_ftf@mail.ru> 1393176094 +0600\n\nFIXME: Created example\n\nCloses PC4-12547")
        end

        before { git_master.stub(:gcommit).and_return gcommit }

        it { expect(master.extract_body).to eq "http://jira.railsc.ru/browse/PC4-12547" }
      end
    end
  end
end
