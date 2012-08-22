# -*- encoding: utf-8 -*-
module Abak::Flow
  class Config < Struct.new(:api_user, :api_token, :proxy)
    [:api_user, :api_token, :proxy].each {|attribute| define_method("#{attribute}?") { !send(attribute).to_s.empty? } }

    def self.current
      return @current_config unless @current_config.nil?

      HighLine.color_scheme = HighLine::SampleColorScheme.new
      git_reader = Hub::Commands.send(:git_reader)

      api_user  = git_reader.read_config('abak.apiuser')
      api_token = git_reader.read_config('abak.apitoken')
      proxy     = git_reader.read_config('abak.proxy')
      env_proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']

      @current_config = new(api_user, api_token, proxy || env_proxy)
    end
  end
end