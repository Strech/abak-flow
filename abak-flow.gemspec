# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "abak-flow/version"

Gem::Specification.new do |s|
  s.name        = "abak-flow"
  s.version     = Abak::Flow::VERSION
  s.authors     = ["Strech (aka Sergey Fedorov)"]
  s.email       = ["oni.strech@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Совмещение 2-х подходов разработки Git-flow & Github-flow}
  s.description = %q{Простой набор правил и комманд, заточеных для работы в git-flow с использование в качестве удаленного репозитория github}

  s.rubyforge_project = "abak-flow"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'hub'
  s.add_development_dependency "commander"

  s.add_runtime_dependency 'hub'
  s.add_runtime_dependency 'commander'
end
