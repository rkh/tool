module Tool
  module Lock
    if defined? Rubinius
      def synchronize
        Rubinius.synchronize(self) { yield }
      end
    else
      require 'thread'
      @lock = Mutex.new

      def self.synchronize(&block)
        @lock.synchronize(&block)
      end

      def synchronize(&block)
        Lock.synchronize { @lock, @locked_by = Mutex.new, nil unless lock? } unless lock?
        return yield if @locked_by == Thread.current
        @lock.synchronize do
          @locked_by = Thread.current
          result     = yield
          @locked_by = nil
          result
        end
      end

      private

      def lock?
        instance_variable_defined? :@lock
      end
    end
  end
end
