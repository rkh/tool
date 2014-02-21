require 'tool/decoration'

describe Tool::Decoration do
  shared_examples :decorate do
    specify "with block" do
      method = nil
      subject.decorate(-> { 42 }) { |m| method = m }
      expect(method).not_to be_nil
      expect(subject.new.send(method)).to be == 42
    end

    specify "without block" do
      method = nil
      subject.decorate { |m| method = m }
      expect(method).to be_nil
      subject.send(:define_method, :foo) { }
      expect(method).to be == :foo
    end

    specify "multiple decorations" do
      calls = []
      subject.decorate { |m| calls << :a }
      subject.decorate { |m| calls << :b }
      expect(calls).to be_empty
      subject.send(:define_method, :foo) { }
      expect(calls).to be == [:a, :b]
    end

    specify "multiple methods" do
      calls = []
      subject.decorate { |m| calls << :a }
      subject.send(:define_method, :foo) { }
      subject.send(:define_method, :bar) { }
      expect(calls).to be == [:a]
    end
  end

  context "extending a class" do
    subject { Class.new.extend(Tool::Decoration) }
    include_examples(:decorate)
  end

  context "including in a module" do
    subject { Class.new.extend(Module.new { include Tool::Decoration }) }
    include_examples(:decorate)
  end

  context "including in a module" do
    subject do
      Class.new(Module) do
        def new(*) Object.new.extend(self) end
        include Tool::Decoration
      end.new
    end
    include_examples(:decorate)
  end
end
