require "bundler/gem_tasks"

require "yard"
require "yard-tomdoc"
require "cane/rake_task"
require "rspec/core/rake_task"

desc "Ready check"
task default: [:quality, :coverage, :doc]

RSpec::Core::RakeTask.new(:coverage) do |rspec|
  ENV['COVERAGE'] = "true"
end

Cane::RakeTask.new(:quality) do |cane|
  cane.abc_max = 15
  cane.abc_glob = cane.style_glob = cane.doc_glob = '{lib}/**/*.rb'
  cane.style_measure = 120
  cane.parallel = false
end

YARD::Rake::YardocTask.new(:doc) do |yard|
  yard.files   = %w({apps,models,lib}/**/*.rb)
  yard.options = %w(--embed-mixins --protected --plugin tomdoc)
end