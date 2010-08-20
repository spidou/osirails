module ActionView
  module Helpers
    module FormOptionsHelper
      # TODO rewrite comment for that method
      #
      def local_auto_complete_field(field_id, entries, options = {})
        entries_array = "[#{ entries.map{ |e| "'#{e}'" }.join(',') }]"
        
        function =  "var #{field_id}_local_auto_completer = new Autocompleter.Local("
        function << "'#{field_id}', "
        function << "'" + (options[:update] || "#{field_id}_local_auto_complete") + "', "
        function << "#{entries_array}"
        js_options = {}
        js_options[:choices]        = "#{options[:choices]}"          if options[:choices]
        js_options[:partialSearch]  = "'#{options[:partial_search]}'" if options[:partial_search]
        js_options[:fullSearch]     = "'#{options[:full_search]}'"    if options[:full_search]
        js_options[:partialChars]   = "#{options[:partial_chars]}"    if options[:partial_chars]
        js_options[:minChars]       = "#{options[:min_chars]}"        if options[:min_chars]
        js_options[:ignoreCase]     = "'#{options[:ignore_case]}'"    if options[:ignore_case]
        
        if protect_against_forgery? && js_options[:method] != "'get'"
          js_options[:parameters] = "'#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
        end
        
        { :update_element       => :updateElement,
          :after_update_element => :afterUpdateElement,
          :on_show              => :onShow,
          :on_hide              => :onHide,
          :min_chars            => :minChars }.each do |k,v|
          js_options[v] = options[k] if options[k]
        end

        function << (', ' + options_for_javascript(js_options) + ')')

        javascript_tag(function)
      end
      
      #TODO is that method really used ??
      #
      # The auto_complete_result can of course also be called from a view belonging to the 
      # auto_complete action if you need to decorate it further.
      def local_auto_complete_result(entries, field, phrase = nil)
        return unless entries
        items = entries.map { |entry| content_tag("li", phrase ? highlight(entry[field], phrase) : h(entry[field])) }
        content_tag("ul", items.uniq)
      end
      
      # Wrapper for text_field with added AJAX autocompletion functionality.
      #
      # In your controller, you'll need to define an action called
      # auto_complete_for to respond the AJAX calls,
      # 
      def text_field_with_local_auto_complete_tag(object_name, method_name, entries, tag_options = {}, completion_options = {})
        identifier = completion_options.delete(:identifier)
        identifier ||= generate_random_id
        autocompleter_id = "#{object_name.gsub("]","").gsub("[","_")}_#{method_name}_#{identifier}"
        
        (completion_options[:skip_style] ? "" : local_auto_complete_stylesheet) +
        text_field(object_name, method_name, { :id => "#{autocompleter_id}" }.merge(tag_options)) +
        content_tag("div", "", :id => "#{autocompleter_id}_local_auto_complete", :class => "local_auto_complete") +
        local_auto_complete_field(autocompleter_id, entries, completion_options)
      end

      private
        def local_auto_complete_stylesheet
          content_tag('style', <<-EOT, :type => Mime::CSS)
            div.local_auto_complete {
              width: 350px;
              background: #fff;
            }
            div.local_auto_complete ul {
              border:1px solid #888;
              margin:0;
              padding:0;
              width:100%;
              list-style-type:none;
            }
            div.local_auto_complete ul li {
              margin:0;
              padding:3px;
            }
            div.local_auto_complete ul li.selected {
              background-color: #ffb;
            }
            div.local_auto_complete ul strong.highlight {
              color: #800; 
              margin:0;
              padding:0;
            }
          EOT
        end
    end
    
    class FormBuilder
      def text_field_with_local_auto_complete(method, entries, tag_options = {}, completion_options = {})
        @template.text_field_with_local_auto_complete_tag(@object_name, method, entries, tag_options.merge(:object => @object), completion_options.merge(:object => @object))
      end
    end
  end
end   
