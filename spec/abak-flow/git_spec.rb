# coding: utf-8
require "spec_helper"
require "abak-flow/git"

describe Abak::Flow::Git do
  subject { Abak::Flow::Git }

  it { subject.must_respond_to :git }
end