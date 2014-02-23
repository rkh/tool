*Make sure you view the correct docs: [latest release](http://rubydoc.info/gems/tool/frames), [master](http://rubydoc.info/github/rkh/tool/master/frames).*

General purpose Ruby library used by Sinatra 2.0, Mustermann and related projects.

## Tool::Decoration

Mixin for easy method decorations.

``` ruby
class Frank
  extend Tool::Decoration
  def self.get(path, &block)
    decorate(block) do |method|
      puts "mapping GET #{path} to #{method}"
    end
  end
end

class MyApp < Frank
  get '/hi' do
    "Hello World"
  end

  get '/'; get '/index.php'
  def index
    "This is the index page."
  end
end
```

## Tool::EqualityMap

Weak reference caching based on key equality.
Used for caching. Note that `fetch` is not guaranteed to return the object, even if it has not been
garbage collected yet, especially when used concurrently. Therefore, the block passed to `fetch` has to
be idempotent

``` ruby
class ExpensiveComputation
  @map = Tool::EqualityMap.new

  def self.new(*args)
    @map.fetch(*args) { super }
  end
end
```

## Tool::ThreadLocal

Have thread local values without them actually being thread global.

Advantages:

* Values for all threads are garbage collected when ThreadLocal instance is.
* Values for specific thread are garbage collected when thread is.
* No hidden global state.
* Supports other data types besides hashes.

``` ruby
local = Tool::ThreadLocal.new
local[:key] = "value"

Thread.new do
  local[:key] = "other value"
  puts local[:key] # other value
end.join

puts local[:key] # value
```

Usage with a pre-filled array:

``` ruby
local = Tool::ThreadLocal.new([:foo])
local << :bar

Thread.new { p local }.join # [:foo]
p local # [:foo, :bar]
```

## Tool::WarningFilter

Enables Ruby's built-in warnings (-w) but filters out those caused by third-party gems.
Does not invlove any manual set up.

``` ruby
require 'tool/warning_filter'

Foo = 10
Foo = 20
```