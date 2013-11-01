module Abak
  module Flow; end
end

require "abak-flow/version"       # ✔
require "abak-flow/manager"       # ✔
require "abak-flow/configuration" # ✔
require "abak-flow/repository"    # ✔
require "abak-flow/branch"        # ?
require "abak-flow/pull_request"  # ?
require "abak-flow/request"       # ?
require "abak-flow/visitor"       # ✔


# Может пригодится
# module ::Faraday
#   class Response::RaiseOctokitError < Response::Middleware
#     def error_message_with_trace(response)
#       message = (response[:body].errors || []).map {|error| "=> #{error.code}: #{error.message}" }.join("\n")

#       [error_message_without_trace(response), message].reject { |m| m.empty? }.join("\n\nДополнительные сообщения:\n")
#     end
#     alias_method :error_message_without_trace, :error_message
#     alias_method :error_message, :error_message_with_trace
#   end
# end
