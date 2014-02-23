# coding: utf-8
require "spec_helper"

describe Abak::Flow::Commands::Compare do
  let(:command) { described_class.new }
  let(:options) { double("Options") }
  let(:run) { command.run(Array.new, options) }
  let(:ansi) { double("ANSI") }
  let(:git) { double("Git") }
  let(:manager) do
    double("Manager", configuration: configuration,
      repository: repository, git: git)
  end

  before do
    stub_const('ANSI', ansi)
    ansi.stub(green: "Success")
    ansi.stub(red: "Fail")
    ansi.stub(yellow: "Warning")

    git.stub(:branch) { |x| x }

    Abak::Flow::Manager.stub(instance: manager)
    Abak::Flow::Visitor.any_instance.stub(:say) { |args| args }
    Abak::Flow::Commands::Compare.any_instance.stub(:say) { |args| args }
    Abak::Flow::Commands::Checkup.any_instance.stub(:say) { |args| args }
  end

  context "when errors occurred" do
    let(:repository) { double("Repository", ready?: false, errors: ["Damn"]) }
    let(:configuration) { double("Configuration", ready?: true, errors: Array.new) }

    it { expect { run }.to raise_error SystemExit }
  end

  context "when no errors occurred" do
    let(:repository) { double("Repository", ready?: true, errors: Array.new, origin: origin) }
    let(:configuration) { double("Configuration", ready?: true, errors: Array.new) }
    let(:origin) { double("Origin", repo: "origin-repo/flow") }

    context "when only head/base is given" do
      let(:current_branch) { double("Current branch", name: "cur-br-name", full: "cur-br-name") }
      let(:master) { double("Master branch", name: "master", full: "master") }

      before do
        options.stub(head: master)
        options.stub(base: nil)
      end

      context "when current branch is master" do
        before do
          Abak::Flow::Branch.any_instance.stub(extract_base_name: master)
          git.stub(current_branch: master)
          master.stub(current: true)

          expect(ansi).to receive(:white)
          expect(ansi).to receive(:green)
        end

        after { run }

        it { expect(git).to receive(:push).with("origin-repo/flow", master) }
      end

      context "when current branch is not master" do
        before do
          Abak::Flow::Branch.any_instance.stub(extract_base_name: current_branch)
          git.stub(current_branch: current_branch)
          master.stub(current: false)
        end

        after { run }

        it do
          expect(ansi).to receive(:yellow)
          expect(ansi).to receive(:green)
        end
      end
    end

    context "when head and base are given" do
      let(:current_branch) { double("Current branch") }
      let(:master) { double("Master branch", name: "master", full: "master") }
      let(:develop) { double("Develop branch", name: "develop", full: "develop") }

      before do
        options.stub(head: master)
        options.stub(base: develop)
      end

      context "when current branch is not head" do
        before do
          git.stub(current_branch: current_branch)
          master.stub(current: false)
        end

        after { run }

        it do
          expect(ansi).to receive(:yellow)
          expect(ansi).to receive(:green)
        end
      end

      context "when current branch is head" do
        before do
          git.stub(current_branch: master)
          master.stub(current: true)

          expect(ansi).to receive(:white)
          expect(ansi).to receive(:green)
        end

        after { run }

        it { expect(git).to receive(:push).with("origin-repo/flow", master) }
      end
    end
  end
end