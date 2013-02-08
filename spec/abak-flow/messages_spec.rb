# coding: utf-8
require "spec_helper"

class Abak::Flow::Messages
  module Config
    def self.init; end

    class << self
      attr_accessor :locale
    end
  end
end

def translate
  ->(k) do
    case k
    when :header then "+HEADER+"
    when :hello then "pew"
    when :linux then "pow"
    end
  end
end

require "abak-flow/messages"
describe Abak::Flow::Messages do
  subject { Abak::Flow::Messages.new "scope" }

  describe "Interface" do
    it { subject.must_respond_to :to_s }
    it { subject.must_respond_to :each }
    it { subject.must_respond_to :push }
    it { subject.must_respond_to :<< }
    it { subject.must_respond_to :header }
    it { subject.must_respond_to :pretty_print }
    it { subject.must_respond_to :pp }
  end

  describe "Inner methods" do
    describe "#scope_key" do
      it "should return scope with locale" do
        Abak::Flow::Messages::Config.stub(:locale, :ru) do
          subject.send(:scope_key).must_equal "ru.scope"
        end
      end
    end
  end

  describe "Public methods" do
    describe "#header" do
      it "should print +HEADER+" do
        subject.stub(:translate, translate) do
          subject.header.must_equal "+HEADER+"
        end
      end
    end

    describe "#push" do
      it { subject.elements.must_equal [] }

      it "should push one element" do
        subject.push "hello"
        subject.elements.must_equal [:hello]
      end

      it "should push two elements" do
        subject.push "hello"
        subject.push "world"
        subject.elements.must_equal [:hello, :world]
      end
    end

    describe "#each" do
      it { -> { subject.each }.must_raise ArgumentError }
      it "should work with blocks and return array" do
        tested = []

        subject.stub(:translate, translate) do
          subject.push "hello"
          subject.push "linux"

          subject.each { |e| tested << "*#{e}*" }
        end

        tested.must_equal %w[*pew* *pow*]
      end
    end

    describe "#to_s" do
      it "should return empty string" do
        subject.stub(:translate, translate) do
          subject.to_s.must_be_empty
        end
      end

      it "should translate all elements and concatinate them" do
        subject.stub(:translate, translate) do
          subject.push "hello"
          subject.push "linux"

          subject.to_s.must_equal "1. pew\n2. pow"
        end
      end
    end

    describe "#pretty_print" do
      it "should return empty string" do
        subject.stub(:translate, translate) do
          subject.pretty_print.must_be_empty
        end
      end

      it "should translate all elements and concatinate them with header" do
        subject.stub(:translate, translate) do
          subject.push "hello"
          subject.push "linux"

          subject.pretty_print.must_equal "+HEADER+\n\n1. pew\n2. pow"
        end
      end
    end
  end
end