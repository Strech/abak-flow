# coding: utf-8
require "spec_helper"

describe Abak::Flow::GithubClient do
  subject { described_class }

  it { should respond_to :connection }
end