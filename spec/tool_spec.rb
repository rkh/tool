require 'tool'

describe Tool do
  describe :set do
    let(:object) { Object.new }

    it 'defines a getter' do
      Tool.set(object, :foo, :bar)
      object.foo.should be == :bar
    end

    it 'defines a setter' do
      Tool.set(object, :foo, :bar)
      object.foo = :foo
      object.foo.should be == :foo
    end

    it 'defines a flag' do
      Tool.set(object, :foo, :bar)
      object.should be_foo
      object.foo = false
      object.should_not be_foo
    end

    it 'takes a block' do
      Tool.set(object, :foo) { :bar }
      object.foo.should be == :bar
      object.should be_foo
    end

    it 'adds a setter, even with a block' do
      Tool.set(object, :foo) { :bar }
      object.foo = false
      object.should_not be_foo
    end

    it 'uses the blocks value as flag' do
      Tool.set(object, :foo) { false }
      object.should_not be_foo
    end

    it 'runs the block more than once' do
      counter = 0
      Tool.set(object, :foo) { counter += 1 }
      object.foo.should be == 1
      object.foo.should be == 2
    end

    it 'wraps a block passed to the setter' do
      Tool.set(object, :foo) { :bar }
      object.foo = proc { false }
      object.should be_foo
      object.foo.should be_a(Proc)
    end

    it 'allows passing in a hash' do
      Tool.set(object, :foo => :bar)
      object.foo.should be == :bar
    end

    it 'allows passing in nil' do
      Tool.set(object, :foo, nil)
      object.foo.should be_nil
    end

    it 'does not use the passed block if nil is given' do
      Tool.set(object, :foo, nil) { :bar }
      object.foo.should be_nil
      object.should_not be_foo
    end

    it 'inherits class settings' do
      a = Class.new
      b = Class.new(a)

      Tool.set(a, :foo, :bar)
      b.foo.should be == :bar
    end

    it 'allows overriding class settings in subclasses' do
      a = Class.new
      b = Class.new(a)

      Tool.set(a, :foo, :bar)
      b.foo = :foo

      a.foo.should be == :bar
      b.foo.should be == :foo
    end
  end
end
