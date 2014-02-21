require 'delegate'

module Tool
  class WarningFilter < DelegateClass(IO)
    $stderr  = new($stderr)
    $VERBOSE = true

    def write(line)
      super if line !~ /^\S+gems\/ruby\-\S+:\d+: warning:/
    end
  end
end

