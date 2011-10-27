Sane tools for Ruby without monkey-patching. This is basically code usually
copy from one project to another.

Goal of this library is to be lightweight and unobtrusive, so you don't have
to feel guilty for using it. Mixins are lazy-loaded.

# Included Tools

## Tool::Autoloader

Sets up `autoload` directives for nested constants. Has the advantage of
setting these up when included instead of hooking into `const_missing`, like
ActiveSupport does. The means it is fast, transparent, and does not alter
constant lookup in any way.

``` ruby
module Foo
  include Tool::Autoloader
end
```

If you don't want to include the module, use `setup`:

``` ruby
Tool::Autoloader.setup Foo
```

## Tool::Lock

Adds a `synchronize` method that behaves like `Rubinius.synchronize(self)`,
i.e. recursively going through the lock will not result in a deadlock:

``` ruby
class Foo
  include Tool::Lock

  def recursive_fun(i = 0)
    return i if i == 5
    # THIS NEEDS TO BE THREAD-SAFE!!!
    synchronize { recursive_fun(i + 1) }
  end
end
```

It will use `Rubinius.synchronize` when on Rubinius.

## Tool.set

Simplified version of Sinatra's set:

``` ruby
class Foo
  Tool.set(self, :foo, :foo)
end

class Bar < Foo
end

Bar.foo # => :foo

Bar.foo = :bar
Bar.foo # => :bar

Foo.foo # => :foo
```
