require 'tool/thread_local'

describe Tool::ThreadLocal do
  describe :__getobj__ do
    specify 'normal access' do
      subject[:foo] = 'bar'
      expect(subject[:foo]).to be == 'bar'
    end

    specify 'concurrent access' do
      subject[:foo] = 'bar'
      value = Thread.new { subject[:foo] = 'baz' }.value
      expect(value).to be == 'baz'
      expect(subject[:foo]).to be == 'bar'
    end

    specify 'with an array as value' do
      list = Tool::ThreadLocal.new([])
      foo  = Thread.new { 10.times { list << :foo; sleep(0.01) }; list.to_a }
      bar  = Thread.new { 10.times { list << :bar; sleep(0.01) }; list.to_a }
      expect(list).to be_empty
      list << :list
      expect(list)      .to be == [ :list ]
      expect(foo.value) .to be == [ :foo  ] * 10
      expect(bar.value) .to be == [ :bar  ] * 10
    end

    specify 'deals with garbage collected threads' do
      subject[:a] = 'A'

      Thread.new do
        subject[:b] = 'B'
        Thread.new do
          subject[:c] = 'C'
        end.value
      end.value

      GC.start
      expect(subject[:a]).to be == 'A'
    end
  end

  describe :__size__ do
    specify 'with one thread' do
      subject[:a] = 'A'
      expect(subject.__size__).to be == 1
    end

    specify 'with multiple threads' do
      subject[:a] = 'A'
      thread = Thread.new { subject[:b] = 'B'; sleep }
      sleep 0.01
      expect(subject.__size__).to be == 2
      thread.kill
    end

    specify 'with dead threads' do
      subject[:a] = 'A'

      Thread.new do
        subject[:b] = 'B'
        Thread.new do
          subject[:c] = 'C'
        end.value
      end.value

      GC.start
      expect(subject.__size__).to be == 1
    end
  end
end
