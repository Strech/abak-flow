# coding: utf-8
require "spec_helper"
require "abak-flow/system"

describe Abak::Flow::System do
  subject { Abak::Flow::System }

  it { subject.must_respond_to :ready? }
  it { subject.must_respond_to :recommendations }
  it { subject.must_respond_to :information }

  # TODO : Добавить проверки что без ready? доступны метода :recommendations, :information и они не nil
end