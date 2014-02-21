require 'tool/thread_local'

module Tool
  # Mixin for easy method decorations.
  #
  # @example
  #   class Frank
  #     extend Tool::Decoration
  #     def self.get(path, &block)
  #       decorate(block) do |method|
  #         puts "mapping GET #{path} to #{method}"
  #       end
  #     end
  #   end
  #
  #   # Output:
  #   #   mapping GET /hi to __generated1
  #   #   mapping GET / to index
  #   #   mapping GET /index.php to index
  #   class MyApp < Frank
  #     get '/hi' do
  #       "Hello World"
  #     end
  #
  #     get '/'; get '/index.php'
  #     def index
  #       "This is the index page."
  #     end
  #   end
  module Decoration
    module Initializer
      def initialize(*)
        setup_decorations
        super
      end
    end

    module Setup
      def included(object)
        super
        case object
        when Class  then object.send(:include, Initializer)
        when Module then object.extend(Setup)
        end
      end

      def extended(object)
        object.send(:setup_decorations)
      end
    end

    extend Setup

    def decorate(block = nil, name: "generated", &callback)
      @decorations << callback

      if block
        alias_name = "__" << name.to_s.downcase.gsub(/[^a-z]+/, ?_) << ?1
        alias_name = alias_name.succ while respond_to? alias_name, true
        without_decorations { define_method(name, &block) }
        alias_method(alias_name, name)
        remove_method(name)
        private(alias_name)
      end
    end

    def without_decorations
      @decorations.clear if was = @decorations.to_a.dup
      yield
    ensure
      @decorations.replace(was) if was
    end

    def method_added(name)
      @decorations.each { |d| d.call(name) }.clear
      super
    end

    def setup_decorations
      @decorations = Tool::ThreadLocal.new([])
    end

    private :method_added, :setup_decorations
    private_constant :Initializer, :Setup
  end
end
