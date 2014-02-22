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
    def initialize(default = {})
      @mutex = Mutex.new
      @default = default.dup
      @map = {}
    end

    # @!visibility private
    def __getobj__
      ref = Thread.current[:weakref] ||= WeakRef.new(Thread.current)
      @map.delete_if { |key, value| !key.weakref_alive? }
      @mutex.synchronize { @map[ref] ||= @default.dup }
    end
  end
end