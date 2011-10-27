require 'tool'

describe Tool::Lock do
  before do
    Thread.abort_on_exception = true
  end

  let(:object) { Object.new.extend(Tool::Lock) }
  let(:track) { [] }

  def synchronize(&block)
    object.synchronize(&block)
  end

  it 'runs the given block' do
    synchronize { track << :ran }
    track.should be == [:ran]
  end

  it 'locks for other threads' do
    a = Thread.new { synchronize { sleep(0.2) and track << :first } }

    sleep 0.1
    b = Thread.new { synchronize { track << :second } }

    a.join
    b.join

    track.should be == [:first, :second]
  end

  it 'is no global lock' do
    a = Thread.new { Object.new.extend(Tool::Lock).synchronize { sleep(0.1) and track << :first } }
    b = Thread.new { Object.new.extend(Tool::Lock).synchronize { track << :second } }

    a.join
    b.join

    track.should be == [:second, :first]
  end

  it 'has no issue with recursion' do
    synchronize { synchronize { } }
  end
end
