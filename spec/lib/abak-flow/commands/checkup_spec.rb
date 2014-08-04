# coding: utf-8
require "spec_helper"

describe Abak::Flow::Commands::Checkup do
  let(:command) { described_class.new }
  let(:options) { double("Options") }
  let(:locale) { Abak::Flow::Locale.new("en") }
  let(:run) { command.run(Array.new, options) }
  let(:manager) do
    double("Manager", configuration: configuration,
      repository: repository, locale: locale)
  end

  before do
    I18n.stub(:t) { |args| args }

    Abak::Flow::Manager.stub(instance: manager)
    Abak::Flow::Commands::Checkup.any_instance.stub(:say) { |args| args }
  end

  context "when no errors occurred" do
    let(:repository) { double("Repository", valid?: true, errors: Array.new) }
    let(:configuration) { double("Configuration", valid?: true, errors: Array.new) }

    it { expect(run).to include "commands.checkup.success" }
  end

  context "when errors occurred" do
    let(:repository) { double("Repository", valid?: false, errors: ["Damn"]) }
    let(:configuration) { double("Configuration", valid?: true, errors: Array.new) }

    it { expect { run }.to raise_error SystemExit }
  end
end
