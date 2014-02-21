$:.unshift File.expand_path("../lib", __FILE__)
require "tool/version"

Gem::Specification.new do |s|
  s.name                  = "tool"
  s.version               = Tool::VERSION
  s.author                = "Konstantin Haase"
  s.email                 = "konstantin.mailinglists@googlemail.com"
  s.homepage              = "https://github.com/rkh/tool"
  s.summary               = %q{general purpose library}
  s.description           = %q{general purpose Ruby library used by Sinatra 2.0, Mustermann and related projects}
  s.license               = 'MIT'
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files      = `git ls-files -- *.md`.split("\n")
  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'rspec', '~> 3.0.0.beta'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coveralls'
end
