# coding: utf-8
require "spec_helper"
require "abak-flow/branches"

describe Abak::Flow::Branches do
  let(:described_class) { Abak::Flow::Branches }
  
  describe "Interface" do
    it { described_class.must_respond_to :current_branch }
  end
end