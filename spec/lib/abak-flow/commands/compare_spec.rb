# coding: utf-8
require "spec_helper"

describe Abak::Flow::Commands::Compare do
  let(:command) { described_class.new }
  let(:options) { double("Options") }
  let(:run) { command.run(Array.new, options) }
  let(:git) { double("Git") }
  let(:github) { double("Github", web_endpoint: "github.com") }
  let(:master) { double("Master branch", name: "master", full: "master", to_s: "master") }
  let(:develop) { double("Develop branch", name: "develop", full: "develop", to_s: "develop") }
  let(:noname) { double("Noname branch", name: "noname", full: "noname", to_s: "noname") }
  let(:manager) do
    double("Manager", configuration: configuration,
      repository: repository, git: git, github: github)
  end

  before do
    git.stub(:branch) { |x| x }
    I18n.stub(:t) { |args| args }

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
    let(:repository) { double("Repository", ready?: true, errors: Array.new, origin: origin, upstream: upstream) }
    let(:configuration) { double("Configuration", ready?: true, errors: Array.new) }
    let(:origin) { double("Origin", repo: "origin-repo/flow", to_s: "origin-repo/flow") }
    let(:upstream) { double("Upstream", owner: "User") }

    context "when only head/base is given" do
      before do
        options.stub(head: master)
        options.stub(base: nil)
      end

      context "when current branch is master" do
        before do
          Abak::Flow::Branch.any_instance.stub(extract_base_name: master)
          git.stub(current_branch: master)
          master.stub(current: true)

          expect(git).to receive(:push).with("origin-repo/flow", master)
        end

        it { expect(run).to include "github.com/origin-repo/flow/compare/User:master...master" }
      end

      context "when current branch is not master" do
        before do
          Abak::Flow::Branch.any_instance.stub(extract_base_name: noname)
          git.stub(current_branch: noname)
          master.stub(current: false)
        end

        after { run }

        it { expect(run).to include "github.com/origin-repo/flow/compare/User:noname...master" }
      end
    end

    context "when head and base are given" do
      before do
        options.stub(head: master)
        options.stub(base: develop)
      end

      context "when current branch is not head" do
        before do
          git.stub(current_branch: noname)
          master.stub(current: false)
        end

        it { expect(run).to include "github.com/origin-repo/flow/compare/User:develop...master" }
      end

      context "when current branch is head" do
        before do
          git.stub(current_branch: master)
          master.stub(current: true)

          expect(git).to receive(:push).with("origin-repo/flow", master)
        end

        it { expect(run).to include "github.com/origin-repo/flow/compare/User:develop...master" }
      end
    end
  end
end