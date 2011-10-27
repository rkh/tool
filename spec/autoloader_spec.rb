require 'tool'
require 'autoloader/foo'

describe Tool::Autoloader do
  # poor man's matchers
  def autoload(const) be_autoload(const) end
  def start_with(str) be_start_with(str) end

  it 'sets up autoloading' do
    Autoloader::Foo.should autoload(:Bar)
    Autoloader::Foo::Bar.name.should start_with("Autoloader::Foo::")
  end

  it 'creates modules for subdirectories' do
    Autoloader::Foo.should_not autoload(:Baz)
    Autoloader::Foo::Baz.should autoload(:Bar)
  end

  it 'handles nested constants with same name' do
    Autoloader::Foo::Baz::Foo.should_not be == Autoloader::Foo
  end

  it 'does not automatically set up autoloading for autoloaded constants' do
    Autoloader::Foo::Blah.should_not autoload(:Boom)
    expect { Autoloader::Foo::Blah::Boom }.to raise_error(NameError)
  end

  it 'does not override existing constants' do
    Autoloader::Foo::Answer.should be == 42
  end

  it 'loads VERSION' do
    Autoloader::Foo.should autoload(:VERSION)
    Autoloader::Foo.should_not autoload(:Version)
    Autoloader::Foo::VERSION.should be == 1337
  end

  it 'loads CLI' do
    Autoloader::Foo.should autoload(:CLI)
    Autoloader::Foo.should_not autoload(:Cli)
  end

  it 'loads camel-cased constants' do
    Autoloader::Foo.should autoload(:FooBar)
    Autoloader::Foo.should_not autoload(:Foo_bar)
  end
end
