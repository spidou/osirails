require 'action_view/helpers/form_helper'

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
          indentation_value = @object.respond_to?("ancestors") && @object.class.find_by_id(value) ? options[:indentation].to_i*@object.class.find(value).ancestors.size : 0
          style_attribute = " style=\"padding-left:#{indentation_value}px\""
          options_tag << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{style_attribute}>#{html_escape(text.to_s)}</option>)
        end

        options_for_select.join("\n")
      end
      
      # this method is a copy of the code from Rails v2.3.4
      #TODO remove that method once we have migrated to Rails 2.3.4
      def grouped_collection_select(object, method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_grouped_collection_select_tag(collection, group_method, group_label_method, option_key_method, option_value_method, options, html_options)
      end
      
      def collection_select_with_custom_choice(object_name, method_name, choice_method_name, collection, value_method, text_method, options = {}, select_options = {}, text_field_options = {}, link_options = {})
        options = { :last_option_value  => -1,
                    :last_option_text   => "Autre..." }.merge(options) #TODO use i18n for last_option_text
        
        last_option = Struct.new("LastOptionForCollectionSelect", value_method, text_method).new(options[:last_option_value], options[:last_option_text])
        collection = collection + [ last_option ]
        InstanceTag.new(object_name, method_name, self, options.delete(:object)).to_collection_select_tag_with_custom_choice(choice_method_name, collection, value_method, text_method, options, select_options, text_field_options, link_options)
      end
      
      def label(object_name, method, text = nil, options = {})
        ###### hack by Ronnie Heritiana RABENANDRASANA for I18n management
        if text.nil?
          text = i18n_label(options[:object].class,method)
        end
        ###### end hack
        
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_label_tag(text, options)
      end
      
      # Creates a label without the default 'for' attribute option that raises a
      # warning when using the method 'label' without a corresponding object id,
      # such as labels not called inside a 'form_for'
      #
      # ==== Example
      #   <%= simple_label 'Your text' %>
      #   # => <label>Your text</label>
      # 
      # By passing a class and a method, I18n is managed
      # ==== Example 
      #   <%= simple_label :order, :title %>
      #   # => <label>Nom du projet&nbsp;:</label>
      #   thanks to yml file => fr:
      #                           activerecord:
      #                             attributes:
      #                               order:
      #                                 title: "Nom du projet"
      #
      def simple_label(class_or_text, method = nil, options = {})
        if class_or_text.is_a?(Symbol)
          text = i18n_label(class_or_text.to_s.camelize.constantize,method)
        else
          text = class_or_text
        end
        content_tag :label, text, options
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
        identifier = completion_options.delete(:identifier)
        identifier ||= generate_random_id
        
        value = tag_options.delete(:value)
        
        #OPTIMIZE use class instead of style attribute
        tag_options = { :style        => "color: grey; font-style: italic",
                        :value        => value,
                        :restoreValue => value,
                        :id           => "#{object}_#{method}_#{identifier}",
                        :name         => "#{object}[#{method}]" }.merge(tag_options)
        
        update_id = completion_options.delete(:update_id) || "#{object}_#{method}_id"
        
        completion_options =  { :update_id            => update_id,
                                :skip_style           => true,
                                :frequency            => 0.7,
                                :url                  => send("auto_complete_for_#{object}_#{method}_path"),
                                :indicator            => "auto_complete_indicator_#{identifier}",
                                :update_element       => "function(li){
                                                            this.element = $('#{tag_options[:id]}')
                                                            target_value = li.down('.#{object}_#{method}_value')
                                                            if (target_value) { this.element.value = target_value.innerHTML };
                                                            if (this.afterUpdateElement) { this.afterUpdateElement(this.element, li) }
                                                          }",
                                :after_update_element => "function(input,li){
                                                            target_id = li.down('.#{object}_#{method}_id')
                                                            target_value = li.down('.#{object}_#{method}_value')
                                                            if (target_id) { $('#{update_id}').value = target_id.innerHTML }
                                                            if (target_value) { input.setAttribute('restoreValue', target_value.innerHTML); input.value = input.getAttribute('restoreValue'); }
                                                          }"
                              }.merge(completion_options)
        
        if tag_options[:value]
          #OPTIMIZE use class instead of style attribute
          tag_options = { :onfocus   => "if (this.value == this.getAttribute('restoreValue')) { this.value=''; this.style.color='inherit'; this.style.fontStyle='inherit' } else { select() }",
                          :onblur    => "if (this.value == '' || this.value == this.getAttribute('restoreValue')) { this.value = this.getAttribute('restoreValue'); this.style.color='grey'; this.style.fontStyle='italic' } else { this.selectionStart = 0 }"
                        }.merge(tag_options)
        end
        
        method_identifier = tag_options[:id].to_s.gsub("#{object}_", "")
        
        html =  "<div class=\"auto_complete_container\">"
        html << text_field_with_auto_complete(object, method_identifier, tag_options, completion_options)
        html << content_tag(:div, nil, :id => "auto_complete_indicator_#{identifier}", :class => "auto_complete_indicator", :style => "display:none")
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
      
      def calendar_date_field_tag(object_name, method_name, options = {}, text_field_options = {})
        options[:output_format]   ||= "%Y-%m-%d"
        text_field_options[:size] ||= 10
        
        InstanceTag.new(object_name, method_name, self, options.delete(:object)).to_calendar_select_tag(options, text_field_options)
      end
      
      def calendar_datetime_field_tag(object_name, method_name, options = {}, text_field_options = {})
        options[:time_select]       = true
        options[:output_format]   ||= "%Y-%m-%d %H:%M:%S"
        text_field_options[:size] ||= 17
        
        InstanceTag.new(object_name, method_name, self, options.delete(:object)).to_calendar_select_tag(options, text_field_options)
      end
      
      private
        def i18n_label(klass,method)
          key = method.to_s.gsub(/_id(s)?$/,"")
          if klass.respond_to?(:human_attribute_name)
            text = klass.human_attribute_name(key)
          else
            text = "#{key}"
          end
          text = (text + I18n.t('label_separator')).gsub(" :", "&#160;:") # &#160; => indivisible space
        end
    end
    
    class InstanceTag #:nodoc:
      include Helpers::AssetTagHelper, Helpers::JavaScriptHelper # used by to_calendar_select_tag
      
      def to_collection_select_tag_with_indentation(collection, value_method, text_method, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag(
          "select", add_options(options_from_collection_for_select_with_indentation(collection, value_method, text_method, options, value), options, value), html_options
        )
      end
      
      # this method is a copy of the code from Rails v2.3.4
      #TODO remove that method once we have migrated to Rails 2.3.4
      def to_grouped_collection_select_tag(collection, group_method, group_label_method, option_key_method, option_value_method, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag(
          "select", add_options(option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, value), options, value), html_options
        )
      end
      
      def to_calendar_select_tag(options = {}, text_field_options = {})
        options[:default]                 ||= object.send(@method_name)
        options[:start_year]              ||= 1900
        options[:end_year]                ||= 2999
        options[:time_select]             ||= false
        options[:time_format]             ||= 24
        options[:disabled]                ||= false
        
        options[:default] = options[:default].strftime(options[:output_format]) rescue options[:default]
        
        disabled_textfield                  = options[:disabled] || text_field_options[:disabled]
        formatted_textfield_id              = "#{@object_name.gsub("]","").gsub("[","_")}#{options[:index]}_#{@method_name}"
        text_field_options                  = text_field_options.merge(:id => formatted_textfield_id, :disabled => disabled_textfield, :value => options[:default])
        targetted_textfield_id              = "#{formatted_textfield_id}#{options[:disabled] ? '_for_disabled_calendar' : ''}"
        hidden_field_for_disabled_calendar  = options[:disabled] ? hidden_field_tag("#{formatted_textfield_id}_for_disabled_calendar", nil, :disabled => true) : ''
        
        InstanceTag.new(@object_name, @method_name, self, options.delete(:object)).to_input_field_tag("text", text_field_options) +
          image_tag("calendar.png", {:id => "#{@object_name}_#{@method_name}_#{options[:index]}_trigger", :class => "calendar-trigger"}) +
          javascript_tag("Calendar.setup({range       : [#{options[:start_year]},#{options[:end_year]}],
                                          ifFormat    : '#{options[:output_format]}', 
                                          showsTime   : #{options[:time_select]}, 
                                          timeFormat  : #{options[:time_format]}, 
                                          showOthers  : true, 
                                          inputField  : '#{targetted_textfield_id}', 
                                          button      : '#{@object_name}_#{@method_name}_#{options[:index]}_trigger' });") +
          hidden_field_for_disabled_calendar
      end
      
      def to_collection_select_tag_with_custom_choice(choice_method_name, collection, value_method, text_method, options, select_options, text_field_options, link_options)
        text_field_options = { :class         => "#{choice_method_name}_input",
                               :autocomplete  => "off" }.merge(text_field_options)
        
        before_select_custom_choice = options.delete(:before_select_custom_choice)  || ""
        on_select_custom_choice     = options.delete(:on_select_custom_choice)      || "this.clear().up('.#{choice_method_name}_select_container').hide().up().down('.#{choice_method_name}_input_container').show().down('.#{choice_method_name}_input').focus()"
        after_select_custom_choice  = options.delete(:after_select_custom_choice)   || ""
        
        select_options = { :class     => "#{@method_name}_input",
                           :onchange  => "if (this.value == '#{options[:last_option_value]}') {
  #{before_select_custom_choice};
  #{on_select_custom_choice};
  #{after_select_custom_choice}
} else {
  #{select_options.delete(:onchange)}
}" }.merge(select_options)
        
        link_options = { :content   => image_tag("cross_16x16.png", :title => "Annuler", :alt => "Annuler"),
                         :function  => "var input_container = this.up('.#{choice_method_name}_input_container'); input_container.down('.#{text_field_options[:class]}').clear(); input_container.hide().up().down('.#{choice_method_name}_select_container').show().down('select').focus();" }.merge(link_options)
        
        show_select = @object.send(@method_name) || InstanceTag.value_before_type_cast(@object, choice_method_name.to_s).blank?
        
        content_tag_without_error_wrapping(
          :div, to_collection_select_tag(collection, value_method, text_method, options, select_options.merge(show_select ? {} : { :value => '' })),
          :class => "#{choice_method_name}_select_container",
          :style => show_select ? '' : 'display:none'
        ) +
        content_tag_without_error_wrapping(
          #OPTIMIZE we shouldn't have to manually add the brackets '[]' after the object_name, but the call of 'to_collection_select_tag_with_custom_choice' remove end brackets to the object_name
          :div, InstanceTag.new("#{@object_name}[]", choice_method_name, self, @object).to_input_field_tag("text", text_field_options.merge(show_select ? { :value => '' } : {})) +
                link_to_function_without_error_wrapping(link_options.delete(:content), link_options.delete(:function), link_options),
          :class => "#{choice_method_name}_input_container",
          :style => show_select ? 'display:none' : ''
        )
      end
    end
    
    class FormBuilder
      attr_accessor :force_show_view, :force_form_view
      
      def collection_select_with_indentation(method, collection, value_method, text_method, options = {}, html_options = {})
        @template.collection_select_with_indentation(@object_name, method, collection, value_method, text_method, options.merge(:object => @object), html_options)
      end
      
      # this method is a copy of the code from Rails v2.3.4
      #TODO remove that method once we have migrated to Rails 2.3.4
      def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
        @template.grouped_collection_select(@object_name, method, collection, group_method, group_label_method, option_key_method, option_value_method, objectify_options(options), @default_options.merge(html_options))
      end
      
      def collection_select_with_custom_choice(method_name, choice_method_name, collection, value_method, text_method, options = {}, select_options = {}, text_field_options = {}, link_options = {})
        @template.collection_select_with_custom_choice(@object_name, method_name, choice_method_name, collection, value_method, text_method, options.merge(:object => @object), select_options, text_field_options, link_options)
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
      
      def calendar_date_select(method, options = {}, text_field_options = {})
        @template.calendar_date_field_tag(@object_name, method, options.merge(:object => @object), text_field_options)
      end
      
      def calendar_datetime_select(method, options = {}, text_field_options = {})
        @template.calendar_datetime_field_tag(@object_name, method, options.merge(:object => @object), text_field_options)
      end
      
      def form_buttons(options = {})
        return unless form_view?
        
        submit_text = options.delete(:submit_text)|| (@object.new_record? ? 'Enregistrer' : 'Enregistrer')
        reset_text  = options.delete(:reset_text) || 'Réinitialiser'
        
        options = { :disable_with => "Enregistrement en cours..." }.update(options)
        
        submit      = @template.submit_tag(submit_text, options)
        reset       = @template.reset(@object_name, reset_text)
        
        @template.content_tag(:p, "#{reset} #{submit}", :class => :form_buttons)
      end
    end
    
  end
end

ActionController::Base.helper ActionView::Helpers::FormOptionsHelper
