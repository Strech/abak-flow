# coding: utf-8
#
# Just an incapsulation of Git Class
require "git"

module Abak::Flow
  module Git

    def self.git
      @@git ||= ::Git.open('.')
    end

  end
end