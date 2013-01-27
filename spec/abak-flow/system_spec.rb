# coding: utf-8
require "spec_helper"
require "abak-flow/system"

describe Abak::Flow::System do
  let(:described_class) { Abak::Flow::System }

  it { described_class.must_respond_to :ready? }
  it { described_class.must_respond_to :recommendations }
  it { described_class.must_respond_to :information }

  # TODO : Добавить проверки что без ready? доступны метода :recommendations, :information и они не nil
end