require 'action_view/helpers/form_helper'
require 'digest/sha1'

module ActionView
  module Helpers
    module FormOptionsHelper
      def collection_select_with_indentation(object, method, collection, value_method, text_method, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_collection_select_tag_with_indentation(collection, value_method, text_method, options, html_options)
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
      
      def collection_select_with_option_groups(object_name, method, collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil, options = {})
        html = ""
        html << "<span class=\"fieldWithErrors\">" if options[:object].errors.on(method)
        html <<   "<select name='#{object_name}[#{method}]' id='#{object_name}_#{method}'>"
        html <<     "<option value=\"\">#{options[:include_blank]}</option>" if options[:include_blank]
        html <<     option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key)
        html <<   "</select>"
        html << "</span>" if options[:object].errors.on(method)
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
        
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_label_tag(text, options)
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
      
      def custom_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
        random_id_for_indicator = Digest::SHA1.hexdigest(rand(1000000).to_s)
        #OPTIMIZE use class instead of style attribute
        tag_options = { :style => "color: grey; font-style: italic" }.merge(tag_options)
        
        completion_options =  { :update_id => "#{object}_#{method}_id" }.merge(completion_options)
        completion_options =  { :skip_style           => true,
                                :url                  => send("auto_complete_for_#{object}_#{method}_path"),
                                :indicator            => "auto_complete_#{random_id_for_indicator}",
                                :update_element       => "function(li){
                                                            this.element = $('#{object}_#{method}')
                                                            this.element.value = li.down('.#{object}_#{method}_value').innerHTML;
                                                            if (this.afterUpdateElement) { this.afterUpdateElement(this.element, li) }
                                                          }",
                                :after_update_element => "function(input,li){
                                                            $('#{completion_options[:update_id]}').value = li.down('.#{object}_#{method}_id').innerHTML;
                                                          }"
                              }.merge(completion_options)
        
        if tag_options[:value]
          #OPTIMIZE use class instead of style attribute
          tag_options = { :onfocus   => "if (this.value == '#{tag_options[:value]}') { this.value=''; this.style.color='inherit'; this.style.fontStyle='inherit' } else { select() }",
                          :onblur    => "if (this.value == '' || this.value == '#{tag_options[:value]}') { this.value = '#{tag_options[:value]}'; this.style.color='grey'; this.style.fontStyle='italic' } else { this.selectionStart = 0 }"
                        }.merge(tag_options)
        end
        
        html =  "<div class=\"auto_complete_container\""
        html << text_field_with_auto_complete(object, method, tag_options, completion_options)
        html << content_tag(:div, nil, :id => "auto_complete_#{random_id_for_indicator}", :class => "auto_complete_indicator", :style => "display:none")
        html << "</div>"
      end
      
      # Use this method in your view to generate a return for the AJAX autocomplete requests.
      #
      # Example action:
      #
      #   def auto_complete_for_item_title
      #     @items = Item.find(:all, 
      #       :conditions => [ 'LOWER(description) LIKE ?', 
      #       '%' + request.raw_post.downcase + '%' ])
      #     render :inline => "<%= custom_auto_complete_result(@items, 'title description') %>"
      #   end
      #
      # The auto_complete_result can of course also be called from a view belonging to the 
      # auto_complete action if you need to decorate it further.
      def custom_auto_complete_result(entries, fields, phrase = nil)
        return unless entries
        fields = fields.split(" ")
        items = entries.map do |entry|
          text = fields.map { |field| entry[field] }.join(" - ")
          #OPTIMIZE return less data to save bandwith, like => { "1" => "reference 1", "2" => "reference 2" }.to_json
          # and make all the treatment by the client (in javascript)
          content_tag 'li', content_tag( 'div', phrase ? highlight(text, phrase) : h(text) ) +
                            content_tag( 'div', h(text),  :style => 'display:none', :class => "#{entry.class.singularized_table_name}_#{fields.first}_value" ) +
                            content_tag( 'div', entry.id, :style => 'display:none', :class => "#{entry.class.singularized_table_name}_#{fields.first}_id" )
        end
        content_tag('ul', items.uniq)
      end
      
      def autoresize_text_area(object_name, method, options = {})
        options[:rows] ||= 2
        options[:cols] ||= 60
        options[:class] = "#{options[:class]}#{options[:class].blank? ? '' : ' '}autoresize_text_area";
        options[:style] = "#{options[:style]}#{options[:style].blank? ? '' : ';'}overflow: hidden";
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
      attr_accessor :force_show_view, :force_form_view
      
      def collection_select_with_indentation(method, collection, value_method, text_method, options = {}, html_options = {})
        @template.collection_select_with_indentation(@object_name, method, collection, value_method, text_method, options.merge(:object => @object), html_options)
      end
      
      def collection_select_with_option_groups(method, collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil, options = {})
        @template.collection_select_with_option_groups(@object_name, method, collection, group_method, group_label_method, option_key_method, option_value_method, selected_key, options.merge(:object => @object))
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
        return form_tag if view_methods.empty? or force_form_view? # return first if second is nil or if we force form view
#        if @template.is_form_view? and !form_tag.nil?
        if !force_show_view? and ( @object.new_record? or (!@object.new_record? and @template.is_form_view?) ) and !form_tag.nil?
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
      
      def force_show_view?
        @force_show_view == true
      end
      
      def force_form_view?
        @force_form_view == true
      end
      
      def show_view?
        ( !@template.is_form_view? and !force_form_view? ) or ( @template.is_form_view? and force_show_view? )
      end
      
      def form_view?
        ( @template.is_form_view? and !force_show_view? ) or ( !@template.is_form_view? and force_form_view? )
      end
      
      def autoresize_text_area(method, options = {})
        @template.autoresize_text_area(@object_name, method, options.merge(:object => @object))
      end
      
      alias_method :text_area_autoresize, :autoresize_text_area
      
      def form_buttons(options={})
        return unless form_view?
        submit_text = options.delete(:submit_text)|| (@object.new_record? ? 'Enregistrer' : 'Enregistrer')
        reset_text  = options.delete(:reset_text) || 'Réinitialiser'
        submit      = @template.submit_tag(submit_text, options)
        reset       = @template.reset(@object_name, reset_text)
        
        @template.content_tag(:p, "#{reset} #{submit}", :class => :form_buttons)
      end
    end
    
  end
end

ActionController::Base.helper ActionView::Helpers::FormOptionsHelper
