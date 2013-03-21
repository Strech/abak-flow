module Abak
  module Flow
    autoload :Git,           "abak-flow/git"
    autoload :Configuration, "abak-flow/configuration"
    autoload :Messages,      "abak-flow/messages"
    autoload :Project,       "abak-flow/project"
    autoload :System,        "abak-flow/system"
    autoload :GithubClient,  "abak-flow/github_client"
    autoload :Branches,      "abak-flow/branches"
    autoload :Branch,        "abak-flow/branch"
    autoload :PullRequest,   "abak-flow/pull_request"
  end
end

require "abak-flow/version"

require "i18n"
require "commander/import"