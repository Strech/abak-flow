# coding: utf-8
if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.minimum_coverage 95
  SimpleCov.start :test_frameworks do
    add_filter "/spec/"
  end
end

require "abak-flow"

Dir["spec/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # ...
end