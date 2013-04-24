# coding: utf-8
require "spec_helper"

describe Abak::Flow::Messages do
  let(:messages) { Abak::Flow::Messages.new "my_scope" }
  subject { messages }

  describe "Interface" do
    it { should respond_to :each }
    it { should respond_to :push }
    it { should respond_to :<< }
    it { should respond_to :to_s }
    it { should respond_to :header }
    it { should respond_to :print }
    it { should respond_to :pretty_print }
    it { should respond_to :pp }
    it { should respond_to :empty? }
    it { should respond_to :translate }
    it { should respond_to :t }
  end

  describe "Public methods" do
    describe "#header" do
      before { I18n.should_receive(:t).with(:header, scope: "my_scope").and_return "+HEADER+" }
      subject { messages.header}

      it { should eq "+HEADER+" }
    end

    describe "#push" do
      context "when no elements pushed" do
        its(:elements) { should be_empty }
      end

      context "when push only one element" do
        before { messages.push :hello }

        its(:elements) { should eq [:hello] }
      end

      context "when push more than one element" do
        before { messages.push :hello }
        before { messages.push :world }

        its(:elements) { should eq [:hello, :world] }
      end
    end

    describe "#each" do
      context "when no block given" do
        it { expect { messages.each }.to raise_error ArgumentError }
      end

      context "when block given" do
        before do
          messages.push :hello
          messages.push :linux

          I18n.should_receive(:t).with(:linux, scope: "my_scope").and_return "linux_t"
          I18n.should_receive(:t).with(:hello, scope: "my_scope").and_return "hello_t"
        end

        it { expect { |b| messages.each(&b) }.to yield_successive_args("hello_t", "linux_t") }
      end
    end

    describe "#to_s" do
      subject { messages.to_s }

      context "when messages are empty" do
        it { should be_empty }
      end

      context "when messages are not empty" do
        before do
          messages.push :hello
          messages.push :linux

          I18n.should_receive(:t).with(:linux, scope: "my_scope").and_return "linux_t"
          I18n.should_receive(:t).with(:hello, scope: "my_scope").and_return "hello_t"
        end

        it { should include "hello_t" }
        it { should include "linux_t" }
      end
    end

    describe "#pretty_print" do
      subject { messages.pp }

      context "when messages are empty" do
        it { should be_empty }
      end

      context "when messages are not empty" do
        before do
          messages.push :hello
          messages.push :linux

          I18n.should_receive(:t).with(:header, scope: "my_scope").and_return "+HEADER+"
          I18n.should_receive(:t).with(:linux, scope: "my_scope").and_return "linux_t"
          I18n.should_receive(:t).with(:hello, scope: "my_scope").and_return "hello_t"
        end

        it { should include "hello_t" }
        it { should include "linux_t" }
        it { should include "+HEADER+" }
      end
    end

    describe "#translate" do
      context "when translate from current scope" do
        before { I18n.should_receive(:t).with(:word, scope: "my_scope").and_return "WORD" }
        subject { messages.t :word }

        it { should eq "WORD" }
      end

      context "when translate from different scope" do
        before { I18n.should_receive(:t).with(:hello, scope: "diff_scope").and_return "HELLO" }
        subject { messages.t :hello, {scope: "diff_scope"} }

        it { should eq "HELLO" }
      end
    end
  end
end