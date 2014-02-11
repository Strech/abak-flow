# coding: utf-8
if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
  end
end

require "abak-flow"

RSpec.configure do |config|
  config.formatter = :progress
  config.order = :random
  config.color = true
end