# coding: utf-8
unless ENV["travis_ci"] == "on"
  require "simplecov"
  SimpleCov.start :test_frameworks
end

require "minitest/autorun"
require "minitest/spec"
require "minitest/mock"

require "ostruct"

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

# TODO : Переделать все это говно под NObject
class GitMock < Struct.new(:remotes, :branches, :current_branch, :config); end
class BranchMock < Struct.new(:full); end
class RemoteMock < ::Struct.new(:name, :url); end

# NullObject based on OpenStruct class
# All unexisting methods return self
#
# See OpenStruct
#
# Examples
#
#   null = NObject.new
#   null.pew                  # => <NObject ...>
#   null.pew = 1              # => 1
#   null.pew                  # => 1
#   null.hello.this.is.me.pew # => 1
#   null.hello                # => <NObject pew=1...>
#
class NObject < OpenStruct
  def method_missing(m, *a, &b)
    super if m.to_s =~ /=$/

    self
  end
end