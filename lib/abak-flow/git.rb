# coding: utf-8
#
# Just an incapsulation of Git Class
require "git"

module Abak::Flow
  module Git

    # TODO : Запоминать включенный гит в переменную
    def self.git
      ::Git.open('.')
    end

  end
end