module Tool
  autoload :Autoloader, 'tool/autoloader'
  autoload :Lock,       'tool/lock'
  autoload :VERSION,    'tool/version'

  def self.set(object, key, value = (no_value = true), &block)
    return key.each_pair { |k,v| set(object, k, v) } if no_value and not block

    block  = proc { value } unless no_value
    sclass = (class << object; self; end)
    setter = self

    sclass.send(:define_method, key, &block)
    sclass.send(:define_method, "#{key}=") { |v| setter.set(self, key, v) }
    sclass.send(:define_method, "#{key}?") { !!__send__(key) }
  end
end
