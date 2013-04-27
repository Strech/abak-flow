# coding: utf-8
require "spec_helper"

describe Abak::Flow::Branches do
  describe "Interface" do
    subject { described_class }

    it { should respond_to :current_branch }
  end

  describe "#current_branch" do
    let(:branch) { double("Branch") }
    let(:git) { double("Git", current_branch: "my_branch", branches: {"my_branch" => branch}) }

    before { described_class.stub(:git).and_return git }
    subject { described_class.current_branch }

    it { should be_kind_of Abak::Flow::Branch }
  end
end