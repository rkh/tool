$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'tool/version'

def gem(*args) sh("gem", *args.map(&:to_s)) end
def git(*args) sh("git", *args.map(&:to_s)) end
  
gem_file = "tool-#{Tool::VERSION}.gem"
version  = "v#{Tool::VERSION}"
message  = "Release #{version}"

task(:spec)                { ruby "-S rspec spec"                        }
task(:build)               { gem :build, 'tool.gemspec'                  }
task(:install => :build)   { gem :install, gem_file                      }
task(:publish => :install) { gem :push, gem_file                         }
task(:commit)              { git :commit, '--allow-empty', '-m', message }
task(:tag)                 { git :tag, '-s', '-m', message, version      }
task(:push)                { git :push                                   }

task :release => [:spec, :commit, :publish, :tag, :push]
task :default => :spec
task :test    => :spec
