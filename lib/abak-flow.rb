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
require "abak-flow/version"

require "commander/import"