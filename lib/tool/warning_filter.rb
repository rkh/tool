require 'delegate'

module Tool
  # Enables Ruby's built-in warnings (-w) but filters out those caused by third-party gems.
  # Does not invlove any manual set up.
  #
  # @example
  #   require 'tool/warning_filter'
  #   Foo = 10
  #   Foo = 20
  class WarningFilter < DelegateClass(IO)
    $stderr  = new($stderr)
    $VERBOSE = true

    # @!visibility private
    def write(line)
      super if line !~ /^\S+gems\/ruby\-\S+:\d+: warning:/
    end
  end
end

