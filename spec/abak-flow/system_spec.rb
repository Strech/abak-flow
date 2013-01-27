# coding: utf-8
require "spec_helper"
require "abak-flow/system"

describe Abak::Flow::System do
  let(:described_class) { Abak::Flow::System }

  it { described_class.must_respond_to :ready? }
  it { described_class.must_respond_to :recomendations }
  it { described_class.must_respond_to :information }
end