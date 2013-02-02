# coding: utf-8
require "spec_helper"
require "abak-flow/github_client"

describe Abak::Flow::GithubClient do
  subject { Abak::Flow::GithubClient }

  it { subject.must_respond_to :connection }
end