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
      
      def collection_select_with_option_groups(object, method, collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil)
        html = "<select name='#{object}[#{method}]' id='#{object}_#{method}'>"
        html << option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key)
        html << "</select>"
        html
      end
      
      # HACKED METHOD (by Mathieu FONTAINE)
      # Returns a label tag tailored for labelling an input field for a specified attribute (identified by +method+) on an object
      # assigned to the template (identified by +object+). The text of label will default to the attribute name unless you specify
      # it explicitly. Additional options on the label tag can be passed as a hash with +options+. These options will be tagged
      # onto the HTML as an HTML element attribute as in the example shown.
      #
      # ==== Examples
      #   label(:post, :title)
      #   # => <label for="post_title">Title</label>
      #
      #
      # ###############
      #   Class Post
      #     cattr_reader :form_labels
      #     @@form_labels[:title] = "A short title :"
      #     @@form_labels[:group] = "Groups :"
      #   end
      #   
      #   label(:post, :title)
      #   # => <label for="post_title">A short title :</label> # if form_labels[:symbol] is defined in the model
      #   
      #   label(:post, :sub_title)
      #   # => <label for="post_sub_title">Sub title</label> # if form_labels[:symbol] is not defined, the 'method_name' is humanized
      #   
      #   label(:post, :group_ids)
      #   # => <label for="post_sub_title">Groups :</label> # if form_labels[:symbol] ends with '_id' or '_ids', the symbol is checked without these characters
      # ###############
      # 
      # ###############
      #   Class Tag
      #     cattr_reader :form_labels
      #     @@form_labels[:name] = ""
      #   end
      #   
      #   fields_for "posts[tag_attributes][]", post do |f|
      #     f.label(:name, :index => nil)
      #   end
      #   # => <label name="posts[tag_attributes][][name]"></label>
      # ###############
      # 
      #
      def label(object_name, method, text = nil, options = {})
        ###### hack by Mathieu FONTAINE
        if text.kind_of?(Hash) # if text is omitted and the third argument is actuallay an option for label tag, so we merge the third arg with the options hash, and we flash the 'text' argument.
          options.merge(text)
          text = nil
        elsif !text.kind_of?(String) and !text.kind_of?(NilClass)
          raise "Unexpected type: 'text' must be either String or Hash. text = #{text.class.name}"
        end
        if text.nil?
          key = method.to_s.gsub(/_id(s)?$/,"").to_sym
          if options[:object].class.respond_to?("form_labels") and !options[:object].class.form_labels[key].nil?
            text = options[:object].class.form_labels[key]
          else
            text = "#{key.to_s}:"
          end
          text = text.gsub(" :", "&#160;:") # &#160; => indivisible space
        end
        ###### end hack
        
        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag(text, options)
      end
      
      # Creates a strong tag
      #
      # ==== Example
      #   <%= strong 'Your text' %>
      #   # => <strong>Your text</strong>
      # 
      # 
      # The content is automatically escaped thanks to the 'h' method
      # ==== Example
      #   <%= strong "<span>Your text</span>" %>
      #   # => <strong>&lt;span&gt;Your text&lt;span&gt;</strong>
      #
      def strong(text, options = {})
        content_tag :strong, h(text), options
      end
      
      def reset(object, text)
        text ||= "Reset"
        "<input type='reset' value='#{text}' name='reset' id='#{object}_reset'/>"
      end
      
      def autoresize_text_area(object_name, method, options = {})
        options = { "style" => "overflow-y: hidden", "class" => "autoresize_text_area", "rows" => options["rows"] }.freeze.merge(options.stringify_keys)
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_text_area_tag(options)
      end
      
      alias_method :text_area_autoresize, :autoresize_text_area
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
      
      def collection_select_with_option_groups(method, collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil)
        @template.collection_select_with_option_groups(@object_name, method, collection, group_method, group_label_method, option_key_method, option_value_method, selected_key)
      end
      
      # Returns either the edit_tag or the view_tag.
      # The *is_form_view*? method of the ApplicationHelper module permits to know if we are in an editable view (add/edit) or not (show)
      # 
      # ==== Parameters
      # *form_tag* : the tag to display if we are in an editable page (add/edit)
      # **view_methods* : the methods to call to display if we are in a view page (show)
      # 
      # ==== Examples
      # First example with a text_field tag and a default attribute (:name)
      #   <%= form.label :name, "Name" %>
      #   <%= form.form_or_view(form.text_field(:name), :name) %>
      #   
      #   # (add/edit)
      #   # => <label>Name</label>
      #   #    <input type="text" value="Your text" />
      #   
      #   # (show)
      #   # => <label>Name</label>
      #   #    <strong>Your text</strong>
      # 
      # Second example with a collection_select tag and nested objects attributes (:group, :name)
      #   <%= form.label :group_name_id, "Group Name" %>
      #   <%= form.form_or_view(form.collection_select(:group_name_id, Group.find(:all), :id, :name),
      #                     :group, :name) %>
      #   
      #   # (add/edit)
      #   # => <label>Group Name</label>
      #   #    <select>
      #   #       <option value="1">Admin</option>
      #   #       <option value="2">User</option>
      #   #    </select>
      #   
      #   # (show)
      #   # => <label>Group Name</label>
      #   #    <strong>Admin</strong> # @user.group.name (see the 2 last args of the 'form_or_view' call method)
      #      
      # Third example with a text_field tag and a custom value for view page
      #   <%= form.form_or_view(form.text_field(:name), "<span>My custom value</span>") %>
      #   
      #   # (add/edit)
      #   # => <label>Name</label>
      #   #    <input type="text" value="Your text" />
      #   
      #   # (show)
      #   # => <span>My custom value</span>
      # 
      def form_or_view(form_tag = nil, *view_methods)
        return if form_tag.nil? and view_methods.nil? # return nothing if both are nil
        return form_tag if view_methods.empty? # return first if second is nil
#        if @template.is_form_view? and !form_tag.nil?
        if ( @object.new_record? or (!@object.new_record? and @template.is_edit_view?) ) and !form_tag.nil?
          form_tag
        else
          view_text = @object
          view_methods.each { |method| view_text = view_text.send(method) if view_text.respond_to?(method) }
          view_text.equal?(@object) ? view_methods.to_s : strong(view_text) #if the view_methods doesn't correspond with any real method, so the view_text still equal to @object. In this case the raw value of 'view_methods' is displayed, otherwise we display a strong tag
        end
      end
      
      # This method permits to display a strong tag using directly the object of the form
      # 
      # ==== Examples
      #   <% fields_for @user do |form| %>
      #     <p>
      #       <%= form.label :username %>
      #       <%= form.strong :username # => <strong>john.doe</strong> %>
      #     </p>
      #     <p>
      #       <%= form.label :group %>
      #       <%= form.strong :group, :name # => <strong>admin</strong> %>
      #     </p>
      #     <p>
      #       <%= form.strong "My custom text" # => <strong>My custom text</strong> %>
      #     </p>
      #   <% end %>
      #
      def strong(*text_methods)
        options = text_methods.pop if text_methods.last.is_a?(Hash)
        
        if text_methods.first.class.equal?(Symbol)
          text = @object
          text_methods.each { |method| text = text.send(method) if text.respond_to?(method) } #OPTIMIZE this is not DRY > put it in a method instead of repeat it!
          text = text_methods.to_s if text.equal?(@object)
        else
          text = text_methods.join(" ")
        end
        @template.strong(text, options)
      end
      
      def reset(text = nil)
        @template.reset(@object_name, text)
      end
      
      def autoresize_text_area(method, options = {})
        @template.autoresize_text_area(@object_name, method, options)
      end
      
      alias_method :text_area_autoresize, :autoresize_text_area
    end
    
  end
end

ActionController::Base.helper ActionView::Helpers::FormOptionsHelper
