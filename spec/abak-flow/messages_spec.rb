# coding: utf-8
require "spec_helper"
require "abak-flow/messages"

describe Abak::Flow::Messages do
  describe "Interface" do
    subject { Abak::Flow::Messages.new "scope" }

    it { subject.must_respond_to :to_s }
    it { subject.must_respond_to :each }
    it { subject.must_respond_to :push }
    it { subject.must_respond_to :<< }
    it { subject.must_respond_to :header }
    it { subject.must_respond_to :pretty_print }
    it { subject.must_respond_to :pp }
  end
end