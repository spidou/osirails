require 'action_view/helpers/tag_helper'
require 'action_view/helpers/prototype_helper'

module ActionView
  module Helpers
    module JavaScriptHelper
      def link_to_function_without_error_wrapping(name, *args, &block)
        error_unwrapping link_to_function(name, args, &block)
      end
      
      ERROR_UNWRAP_DELIMITER = "KEY_DELIMITER"
      
      def error_unwrapping(html_tag)
        wrapped_html = Base.field_error_proc.call(ERROR_UNWRAP_DELIMITER)
        wrapped_html.split(ERROR_UNWRAP_DELIMITER).each do |part|
          html_tag = html_tag.gsub(part, "")
        end
        html_tag
      end
    end
  end
end
