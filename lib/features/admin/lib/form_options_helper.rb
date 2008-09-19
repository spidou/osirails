require 'action_view/helpers/form_helper'

module ActionView
  module Helpers
    
    module FormOptionsHelper
      def collection_select_with_indentation(object, method, collection, value_method, text_method, options = {}, html_options = {})
        InstanceTag.new(object, method, self, nil, options.delete(:object)).to_collection_select_tag_with_indentation(collection, value_method, text_method, options, html_options)
      end
      
      def options_from_collection_for_select_with_indentation(collection, value_method, text_method, options, selected = nil)
        options_tags = collection.map do |element|
          [element.send(text_method), element.send(value_method)]
        end
        options_for_select_with_indentation(options_tags, options, selected)
      end
      
      def options_for_select_with_indentation(container, options, selected = nil)
        container = container.to_a if Hash === container

        options_for_select = container.inject([]) do |options_tag, element|
          text, value = option_text_and_value(element)
          selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
          indentation_value = @object.respond_to?("ancestors") ? options[:indentation].to_i*@object.class.find(value).ancestors.size : 0
          style_attribute = " style=\"padding-left:#{indentation_value}px\""
          options_tag << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{style_attribute}>#{html_escape(text.to_s)}</option>)
        end

        options_for_select.join("\n")
      end
    end
    
    class InstanceTag #:nodoc:
      def to_collection_select_tag_with_indentation(collection, value_method, text_method, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag(
          "select", add_options(options_from_collection_for_select_with_indentation(collection, value_method, text_method, options, value), options, value), html_options
        )
      end
    end
    
    class FormBuilder
      def collection_select_with_indentation(method, collection, value_method, text_method, options = {}, html_options = {})
        @template.collection_select_with_indentation(@object_name, method, collection, value_method, text_method, options.merge(:object => @object), html_options)
      end
    end
    
  end
end