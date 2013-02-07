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

require "abak-flow/messages"
describe Abak::Flow::Messages do
  describe "Interface" do
    subject { Abak::Flow::Messages.new "scope" }

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
      subject { Abak::Flow::Messages.new "the_best_way" }

      it "should return scope with locale" do
        Abak::Flow::Messages::Config.stub(:locale, :ru) do
          subject.send(:scope_key).must_equal "ru.the_best_way"
        end
      end
    end
  end

  describe "Public methods" do
    describe "#header" do
      subject { Abak::Flow::Messages.new "pretty_header" }

      it "should print +HEADER+" do
        st = ->(k) { k == :header ? "+HEADER+" : nil }

        subject.stub(:translate, st) do
          subject.header.must_equal "+HEADER+"
        end
      end
    end

    describe "#push" do
      subject { Abak::Flow::Messages.new "with_elements" }

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
      subject { Abak::Flow::Messages.new "for_each" }

      it { -> { subject.each }.must_raise ArgumentError }
      it "should work with blocks and return array" do
        tested = []
        st = ->(k) do
          case k
          when :hello then "pew"
          when :linux then "pow"
          end
        end

        subject.stub(:translate, st) do
          subject.push "hello"
          subject.push "linux"

          subject.each { |e| tested << "*#{e}*" }
        end

        tested.must_equal %w[*pew* *pow*]
      end
    end

    describe "#to_s" do

    end

    describe "#pretty_print" do

    end
  end
end