# coding: utf-8
#
# Just an incapsulation of Git Class
require "git"
require "singleton"
require "forwardable"

module Abak::Flow
  class Git
    include Singleton
    extend Forwardable

    attr_reader :git
    def_delegators :git, :command, :command_lines

    def initialize
      @git = ::Git.open(".")
    end
  end
end