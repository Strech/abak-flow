# coding: utf-8
#
# Just an incapsulation of Git Class
module Abak::Flow
  module Git
    
    def self.git
      ::Git.open('.')
    end

  end
end