# coding: utf-8
require "spec_helper"
require "abak-flow/git"

describe Abak::Flow::Git do
  let(:described_class) { Abak::Flow::Git }
  
  it { described_class.must_respond_to :git }
end