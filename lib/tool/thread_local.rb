require 'delegate'
require 'weakref'
require 'thread'

module Tool
  class ThreadLocal < Delegator
    def initialize(default = {})
      @mutex = Mutex.new
      @default = default.dup
      @map = {}
    end

    def __getobj__
      ref = Thread.current[:weakref] ||= WeakRef.new(Thread.current)
      @map.delete_if { |key, value| !key.weakref_alive? }
      @mutex.synchronize { @map[ref] ||= @default.dup }
    end
  end
end