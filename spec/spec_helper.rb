# coding: utf-8

require "minitest/autorun"
require "minitest/spec"
require "minitest/mock"

begin
  require 'minitest/pride'
rescue LoadError
  # Continue, but without colors
end

# Default modules
module Abak
  module Flow
  end
end

class GitMock < Struct.new(:remotes, :branches, :current_branch); end
class BranchMock < Struct.new(:full); end
class RemoteMock < ::Struct.new(:name, :url); end