$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'tool/version'

Gem::Specification.new 'tool', Tool::VERSION do |s|
  s.description = "This is basically code usually copy from one project to another"
  s.summary     = "Sane tools for Ruby without monkey-patching"

  s.authors     = ["Konstantin Haase"]
  s.email       = "konstantin.mailinglists@googlemail.com"
  s.homepage    = "http://github.com/rkh/tool"

  s.files       = `git ls-files`.split("\n") - %w[Gemfile .gitignore .travis.yml]
  s.test_files  = s.files.select { |p| p =~ /^spec\/.*_spec.rb/ }

  s.add_development_dependency 'rspec', '~> 2.7'
end
