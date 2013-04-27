# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require "abak-flow/version"

Gem::Specification.new do |s|
  s.name        = "abak-flow"
  s.version     = Abak::Flow::VERSION
  s.authors     = ["Strech (aka Sergey Fedorov)"]
  s.email       = ["oni.strech@gmail.com"]
  s.homepage    = "https://github.com/Strech/abak-flow"
  s.summary     = "Совмещение 2-х подходов разработки Git-flow & Github-flow"
  s.description = "Простой набор правил и комманд, заточеных для работы в git-flow с использование в качестве удаленного репозитория github"

  s.rubyforge_project = "abak-flow"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "octokit",   ">= 1.22.0"
  s.add_runtime_dependency "git",       ">= 1.2.5"
  s.add_runtime_dependency "commander", ">= 4.1.3"
  s.add_runtime_dependency "ruler",     ">= 1.4.2"
  s.add_runtime_dependency "i18n",      ">= 0.6.1"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "yard"
  s.add_development_dependency "yard-tomdoc"
  s.add_development_dependency "cane"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rb-fsevent"
end
