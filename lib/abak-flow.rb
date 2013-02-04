module Abak
  module Flow
  end
end

# TODO : Вынести в отдельный рекваер установки цветовой схемы
#        HighLine.color_scheme = HighLine::SampleColorScheme.new

require "abak-flow/git"
require "abak-flow/project"
require "abak-flow/config"
require "abak-flow/system"
require "abak-flow/github_client"
require "abak-flow/branches"
require "abak-flow/branch"
require "abak-flow/pull_request"
require "abak-flow/version"

require "commander/import"
require "i18n"