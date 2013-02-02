# coding: utf-8
require "spec_helper"
require "abak-flow/branches"

describe Abak::Flow::Branches do
  subject { Abak::Flow::Branches }

  describe "Interface" do
    it { subject.must_respond_to :current_branch }
  end
end