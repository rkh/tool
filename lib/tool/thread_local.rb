require 'delegate'
require 'weakref'
require 'thread'

module Tool
  # Have thread local values without them actually being thread global.
  #
  # Advantages:
  # * values for all threads are garbage collected when ThreadLocal instance is
  # * values for specific thread are garbage collected when thread is
  # * no hidden global state
  # * supports other data types besides hashes.
  #
  # @example To replace Thread.current hash access
  #   local = Tool::ThreadLocal.new
  #   local[:key] = "value"
  #
  #   Thread.new do
  #     local[:key] = "other value"
  #     puts local[:key] # other value
  #   end.join
  #
  #   puts local[:key] # value
  #
  # @example Usage with Array
  #   local = Tool::ThreadLocal.new([:foo])
  #   local << :bar
  #
  #   Thread.new { p local }.join # [:foo]
  #   p local # [:foo, :bar]
  class ThreadLocal < Delegator
    @mutex  ||= Mutex.new
    @locals ||= []

    # Thread finalizer.
    # @!visibility private
    def self.cleanup(id)
      @locals.keep_if do |local|
        next false unless local.weakref_alive?
        local.__cleanup__
        true
      end
    end

    # Generates weak reference to thread and sets up finalizer.
    # @return [WeakRef]
    # @!visibility private
    def self.ref(thread)
      thread[:weakref] ||= begin
        ObjectSpace.define_finalizer(thread, method(:cleanup))
        WeakRef.new(thread)
      end
    end

    # @see #initialize
    # @!visibility private
    def self.new(*)
      result = super(default)
      @mutex.synchronize { @locals << WeakRef.new(result) }
      result
    end

    def initialize(default = {})
      @default = default.dup
      @map     = {}
    end

    # @see Delegator
    # @!visibility private
    def __getobj__
      ref = ::Tool::ThreadLocal.ref(Thread.current)
      @map[ref] ||= @default.dup
    end

    # @return [Integer] number of threads with specific locals
    # @!visibility private
    def __size__
      @map.size
    end

    # Remove locals for dead or GC'ed threads
    # @!visibility private
    def __cleanup__
      @map.keep_if { |key, value| key.weakref_alive? and key.alive? }
    end
  end
end