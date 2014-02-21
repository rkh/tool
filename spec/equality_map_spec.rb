require 'tool/equality_map'

describe Tool::EqualityMap do
  before { GC.disable }
  after { GC.enable }

  describe :fetch do
    specify 'with existing entry' do
      subject.fetch("foo") { "foo" }
      result = subject.fetch("foo") { "bar" }
      expect(result).to be == "foo"
    end

    specify 'with GC-removed entry' do
      subject.fetch("foo") { "foo" }
      expect(subject.map).to receive(:[]).and_return(nil)
      result = subject.fetch("foo") { "bar" }
      expect(result).to be == "bar"
    end
  end
end
