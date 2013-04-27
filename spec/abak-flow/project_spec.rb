# coding: utf-8
require "spec_helper"

describe Abak::Flow::Project do
  let(:origin) { double("Origin", name: "origin", url: "git@github.com:Strech/abak-flow.git") }
  let(:upstream) { double("Upstream", name: "upstream", url: "http://github.com/Godlike/abak-flow-new.git") }
  let(:git) { double("Git", remotes: [origin, upstream]) }
  let(:instance) { Abak::Flow::Project.clone.instance }

  context "when initialize project with two remote repositories" do
    before { Abak::Flow::Project.any_instance.stub(:git).and_return git }

    subject { instance.remotes }

    it { should have_key :origin }
    it { should have_key :upstream }
  end

  context "when initialize project with some wrong repositories" do
    let(:wrong) { double("Wrong", name: "wrong", url: "git@wrong-site.com:Me/wrong-flow.git") }
    let(:git) { double("Git", remotes: [origin, wrong]) }

    before { Abak::Flow::Project.any_instance.stub(:git).and_return git }

    subject { instance.remotes }

    it { should have_key :origin }
    it { should_not have_key :upstream }
  end

  describe "#Remote" do
    before { Abak::Flow::Project.any_instance.stub(:git).and_return git }

    describe "#origin" do
      subject { instance.remotes[:origin] }

      its(:owner) { should eq "Strech" }
      its(:project) { should eq "abak-flow" }
      its(:repo) { should eq origin }
      its(:to_s) { should eq "Strech/abak-flow" }
    end

    describe "#upstream" do
      subject { instance.remotes[:upstream] }

      its(:owner) { should eq "Godlike" }
      its(:project) { should eq "abak-flow-new" }
      its(:repo) { should eq upstream }
      its(:to_s) { should eq "Godlike/abak-flow-new" }
    end
  end
end