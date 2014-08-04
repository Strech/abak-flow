# coding: utf-8

require "ansi/code"
require "commander/blank"
require "commander/command"

module Abak
  module Flow
  end
end

require "abak-flow/version"
require "abak-flow/locale"
require "abak-flow/manager"
require "abak-flow/configuration"
require "abak-flow/repository"
require "abak-flow/branch"
require "abak-flow/pull_request"
require "abak-flow/inspector"
require "abak-flow/errors_presenter"
require "abak-flow/commands/checkup"
require "abak-flow/commands/compare"
require "abak-flow/commands/configure"
require "abak-flow/commands/publish"
require "abak-flow/commands/done"

Abak::Flow::Manager.locale
