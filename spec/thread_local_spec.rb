require 'tool/thread_local'

describe Tool::ThreadLocal do
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
end
