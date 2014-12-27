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
      # Make sure decorations list is initializsed upon instantiation.
      # @!visibility private
      def initialize(*)
        setup_decorations
        super
      end
    end

    module Setup
      # Make sure decorations list is initializsed if Decoration is included.
      # @!visibility private
      def included(object)
        case object
        when Class  then object.send(:include, Initializer)
        when Module then object.extend(Setup)
        end
        super
      end

      # Make sure decorations list is initializsed if Decoration extends an object.
      # @!visibility private
      def extended(object)
        object.send(:setup_decorations)
        super
      end
    end

    extend Setup

    # Set up a decoration.
    #
    # @param [Proc, UnboundMethod, nil] block used for defining a method right away
    # @param [String, Symbol] name given to the generated method if block is given
    # @yield callback called with method name once method is defined
    # @yieldparam [Symbol] method name of the method that is to be decorated
    def decorate(block = nil, name: "generated", &callback)
      @decorations << callback

      if block
        alias_name = "__" << name.to_s.downcase.gsub(/[^a-z]+/, ?_) << ?1
        alias_name = alias_name.succ while private_method_defined? alias_name or method_defined? alias_name
        without_decorations { define_method(name, &block) }
        alias_method(alias_name, name)
        remove_method(name)
        private(alias_name)
      end
    end

    # Runs a given block without applying decorations defined outside of the block.
    # Decorations defined before the block will still be registered after the block.
    #
    # @yield block to run without decorations
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
