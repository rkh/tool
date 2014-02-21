require 'tool/decoration'

class Frank
  extend Tool::Decoration
  def self.get(path, &block)
    decorate(block) do |method|
      puts "mapping GET #{path} to #{method}"
    end
  end
end

class MyApp < Frank
  get '/hi' do
    "Hello World"
  end

  get '/'; get '/index.php'
  def index
    "This is the index page."
  end
end