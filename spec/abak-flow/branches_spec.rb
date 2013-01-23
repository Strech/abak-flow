# coding: utf-8
require "spec_helper"
require "abak-flow/branches"

describe Abak::Flow::Branches do
  let(:described_class) { Abak::Flow::Branches }
  
  describe "Interface" do
    it "should respond to current_branch" do
      described_class.must_respond_to :current_branch
    end
  end
  
end