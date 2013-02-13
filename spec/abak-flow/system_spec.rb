# coding: utf-8
require "spec_helper"

module Abak::Flow::System
  module Project
    class << self
      attr_reader :init, :origin, :upstream
    end
  end

  module Configuration
    class << self
      attr_reader :init, :oauth_user, :oauth_token, :proxy_server
    end
  end

  class Messages
    extend Forwardable

    attr_reader :elements
    def_delegators :elements, :empty?

    def initialize(scope)
      @elements = []
    end

    def push(element)
      @elements << element.to_sym
    end
    alias :<< :push
  end
end

require "abak-flow/system"
describe Abak::Flow::System do
  subject { Abak::Flow::System }

  describe "Interface" do
    it { subject.must_respond_to :ready? }
    it { subject.must_respond_to :recommendations }
    it { subject.must_respond_to :information }
  end

  describe "Public methods" do
    describe "#ready?" do
      it { subject.ready?.must_equal false }

      it "should't be ready when unknown upstream" do
        Abak::Flow::System::Project.stub(:origin, "not_nil") do
          subject.ready?.must_equal false
        end
      end

      it "should't be ready when unknown origin" do
        Abak::Flow::System::Project.stub(:upstream, "not_nil") do
          subject.ready?.must_equal false
        end
      end

      it "should't be ready when unknown config options" do
        Abak::Flow::System::Project.stub(:origin, "not_nil") do
          Abak::Flow::System::Project.stub(:upstream, "not_nil") do
            subject.ready?.must_equal false
          end
        end
      end

      it "should be ready when unknown config proxy" do
        Abak::Flow::System::Project.stub(:origin, "not_nil") do
          Abak::Flow::System::Project.stub(:upstream, "not_nil") do
            Abak::Flow::System::Configuration.stub(:oauth_user, "not_nil") do
              Abak::Flow::System::Configuration.stub(:oauth_token, "not_nil") do
                subject.ready?.must_equal true
              end
            end
          end
        end
      end

      it "should be ready when config proxy is set" do
        Abak::Flow::System::Project.stub(:origin, "not_nil") do
          Abak::Flow::System::Project.stub(:upstream, "not_nil") do
            Abak::Flow::System::Configuration.stub(:oauth_user, "not_nil") do
              Abak::Flow::System::Configuration.stub(:oauth_token, "not_nil") do
                Abak::Flow::System::Configuration.stub(:proxy_server, "not_nil") do
                  subject.ready?.must_equal true
                end
              end
            end
          end
        end
      end
    end

    describe "#recommendations" do
      describe "when system not ready" do
        it "should not be empty" do
          subject.ready?
          subject.recommendations.wont_be_empty
        end
      end

      describe "when system ready" do
        it "should be empty" do
          Abak::Flow::System::Project.stub(:origin, "not_nil") do
            Abak::Flow::System::Project.stub(:upstream, "not_nil") do
              Abak::Flow::System::Configuration.stub(:oauth_user, "not_nil") do
                Abak::Flow::System::Configuration.stub(:oauth_token, "not_nil") do
                  subject.ready?
                  subject.recommendations.must_be_empty
                end
              end
            end
          end
        end
      end
    end

    describe "#information" do
      it "should be empty" do
        subject.ready?
        subject.information.must_be_empty
      end

      it "should't be empty'" do
        Abak::Flow::System::Configuration.stub(:proxy_server, "not_nil") do
          subject.ready?
          subject.information.wont_be_empty
        end
      end
    end

  end
end