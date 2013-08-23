# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require "abak-flow/version"

Gem::Specification.new do |gem|
  gem.name        = "abak-flow"
  gem.version     = Abak::Flow::VERSION
  gem.authors     = ["Strech (aka Sergey Fedorov)"]
  gem.email       = ["oni.strech@gmail.com"]
  gem.homepage    = "https://github.com/Strech/abak-flow"
  gem.summary     = "Совмещение 2-х подходов разработки Git-flow & Github-flow"
  gem.description = "Простой набор правил и комманд, заточеных для работы в git-flow с использование в качестве удаленного репозитория github"

  gem.rubyforge_project = "abak-flow"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "octokit",   ">= 1.22.0"
  gem.add_runtime_dependency "git",       ">= 1.2.5"
  gem.add_runtime_dependency "commander", ">= 4.1.3"
  gem.add_runtime_dependency "ruler",     ">= 1.4.2"
  gem.add_runtime_dependency "i18n",      ">= 0.6.1"
  gem.add_runtime_dependency "ansi",    ">= 1.4.3"
end
