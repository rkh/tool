module Tool
  module Autoloader
    CAPITALIZE = %w[version cli] unless defined? CAPITALIZE

    def self.setup(container, path = caller_dir)
      prefix      = path_for(container)
      full_prefix = path_for(container, true)
      path        = File.expand_path(prefix, path)
      directories = []

      Dir.glob("#{path}/*") do |file|
        base  = File.basename(file, '.rb')
        const = constant_for(base)
        lib   = "#{full_prefix}/#{base}"

        if File.directory? file
          directories << const
        elsif file.end_with? '.rb'
          container.autoload const, lib
        end
      end

      directories.each do |const|
        next if container.const_defined? const
        nested = container.const_set(const, Module.new)
        setup nested, path
      end
    end

    def self.path_for(constant, full = false)
      name = constant.name.dup
      name = name[/[^:]+$/] unless full
      name.gsub! /([A-Z]+)([A-Z][a-z])/,'\1_\2'
      name.gsub! /([a-z\d])([A-Z])/,'\1_\2'
      name.gsub! '::', '/'
      name.tr("-", "_").downcase
    end

    def self.constant_for(file)
      return file.upcase if CAPITALIZE.include? file
      file.split('.', 2).first.split(/[_-]/).map(&:capitalize).join
    end

    def self.capitalize(*args)
      CAPITALIZE.concat(args)
    end

    def self.append_features(base)
      setup(base)
    end

    def self.caller_dir
      caller.each do |line|
        file = File.expand_path(line.split(':', 2).first)
        return File.dirname(file) if file != File.expand_path(__FILE__)
      end
      File.dirname($0)
    end
  end
end
