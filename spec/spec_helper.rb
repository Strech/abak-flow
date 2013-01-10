# coding: utf-8

require 'minitest/autorun'
require 'minitest/spec'
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