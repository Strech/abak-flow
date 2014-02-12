require "bundler/gem_tasks"
require "cane/rake_task"
require "rspec/core/rake_task"

desc "Ready check"
task default: [:quality, :coverage]

RSpec::Core::RakeTask.new(:coverage) do |rspec|
  ENV["C"] = "true"
end

Cane::RakeTask.new(:quality) do |cane|
  cane.abc_max = 15
  cane.abc_glob = cane.style_glob = cane.doc_glob = "{lib}/abak-flow/*.rb"
  cane.style_exclude = %w({lib}/abak-flow/request.rb)
  cane.style_measure = 120
  cane.parallel = false
end