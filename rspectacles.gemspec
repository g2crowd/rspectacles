# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rspectacles/version'

Gem::Specification.new do |s|
  s.name        = 'rspectacles'
  s.version     = RSpectacles::VERSION
  s.authors     = ['Michael Wheeler']
  s.email       = ['mwheeler@g2crowd.com']
  s.homepage    = 'https://github.com/G2Labs-net/rspectacles'
  s.summary     = %q{Visualize rspec test running in the browser}
  s.description = %q{Visualize rspec test running in the browser}
  s.required_ruby_version = '1.9.3'

  s.rubyforge_project = 'rspectacles'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  s.add_development_dependency 'rspec'
  s.add_dependency 'rake'
  s.add_dependency 'thin', '>= 1.5.0'
  s.add_dependency 'sinatra', '~> 1.4.3'
  s.add_dependency 'redis'
  s.add_dependency 'em-hiredis', '~> 0.2.1'
end
