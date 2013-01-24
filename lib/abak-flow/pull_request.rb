# coding: utf-8
#
# Class for pushing/updating/checking pull requests
module Abak::Flow
  class PullRequest

    # 1. State Class
    #
    # => pr = PullRequest.new(*attrs)
    # => pr.valid? -> state.valid?
    # => pr.invalid? -> state.invalid?
    # => pr.state
    # => pr.state.message
    # => pr.state.message.to_s

    # 2. Pull request publishing
    #
    # => pr = PullRequest.new(*attrs)
    # => pr.published?
    # => pr.publish
    # => pr.url
    
    # 3. Statistics & Cleaning
    #
    # => PullRequest.garbage
    # => PullRequest.clean
    # => PullRequest.clean(hard: true)
  end
end