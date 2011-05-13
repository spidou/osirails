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
      
      # this method is inspired from Rails v2.3.4, but we add ability to give params on options
      # 
      # *option_options* permits to give params for each option of the select:
      #
      # grouped_collection_select(:object, :method, collection, :group, :group_label, :option_key, :option_value, {}, {}, { :class => :custom_option })
      #   => <select>
      #       <optgroup>
      #         <option class="custom_option"></option>
      #         <option class="custom_option"></option>
      #       </optgroup>
      #      </select>
      #
      # *option_options* accepts Proc:
      #
      # grouped_collection_select(:object, :method, collection, :group, :group_label, :option_key, :option_value, {}, {}, { :class => Proc.new{ |x| x.closed? ? "closed" : "open" } })
      #   => <select>
      #       <optgroup>
      #         <option class="open"></option>
      #         <option class="close"></option>
      #         <option class="open"></option>
      #         <option class="close"></option>
      #       </optgroup>
      #      </select>
      #
      def grouped_collection_select(object, method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {}, option_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_grouped_collection_select_tag(collection, group_method, group_label_method, option_key_method, option_value_method, options, html_options, option_options)
      end
      
      # add ability to give params on options
      def option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key = nil, option_options = {}) # @override
        collection.inject("") do |options_for_select, group|
          group_label_string = eval("group.#{group_label_method}")
          options_for_select += "<optgroup label=\"#{html_escape(group_label_string)}\">"
          options_for_select += options_from_collection_for_select(eval("group.#{group_method}"), option_key_method, option_value_method, selected_key, option_options)
          options_for_select += '</optgroup>'
        end
      end
      
      # add ability to give params on options
      def options_from_collection_for_select(collection, value_method, text_method, selected = nil, html_options = {}) # @override
        options = collection.map do |element|
          opts = html_options.clone
          opts.each{ |k, v| opts[k] = v.call(element) if v.is_a?(Proc) }
          [element.send(text_method), element.send(value_method), opts]
        end
        options_for_select(options, selected)
      end
      
      # add ability to give params on options
      def options_for_select(container, selected = nil) # @override
        container = container.to_a if Hash === container

        options_for_select = container.inject([]) do |options, element|
          text, value = option_text_and_value([element[0], element[1]])
          html_options = element[2]
          selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
          options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{tag_options(html_options)}>#{html_escape(text.to_s)}</option>)
        end

        options_for_select.join("\n")
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
      def simple_label(class_name, method = nil, options = {})
        if class_name.is_a?(Symbol)
          raise ArgumentError, "#simple_label expected a 'method'" if method.blank?
          text = i18n_label(class_name.to_s.camelize.constantize, method)
        elsif class_name.is_a?(String)
          text = class_name
        else
          raise ArgumentError, "#simple_label expected a Symbol or String as 'class_name', but was <#{class_name.class.name}>"
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
        
        indicator = "auto_complete_indicator_for_#{tag_options[:id]}"
        
        before_after_update_element = completion_options.delete(:before_after_update_element) || ""
        after_after_update_element  = completion_options.delete(:after_after_update_element) || ""
        
        completion_options =  { :skip_style           => true,
                                :frequency            => 0.7,
                                :url                  => send("auto_complete_for_#{object}_#{method}_path"),
                                :update_element       => "function(li){
                                                            this.element = $('#{tag_options[:id]}');
                                                            this.element.value = li.readAttribute('data-autocomplete-value');
                                                            if (this.afterUpdateElement) { this.afterUpdateElement(this.element, li) }
                                                          }",
                                :after_update_element => "function(input,li){
                                                            #{before_after_update_element}
                                                            li.attributes.select(function(attr){  // get all data-autocomplete-* attributes
                                                              return attr.name.startsWith('data-autocomplete-')
                                                            }).each(function(attr){               // and copy these attributes on input field
                                                              input.writeAttribute(attr.name, attr.value)
                                                            })
                                                            var value = li.readAttribute('data-autocomplete-value');
                                                            input.writeAttribute('restoreValue', value);
                                                            input.value = value;
                                                            #{after_after_update_element}
                                                          }",
                                :start_indicator      => "function(){ $('#{indicator}').addClassName('loading'); }",
                                :stop_indicator       => "function(){ $('#{indicator}').removeClassName('loading'); }"
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
        html << content_tag(:div, nil, :id => indicator, :class => "auto_complete_indicator")
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
          content_tag :li, 'data-autocomplete-value' => h(text), 'data-autocomplete-id' => entry.id do
            content_tag :div, phrase ? highlight(text, phrase) : h(text)
          end
        end
        content_tag('ul', items.uniq)
      end
      
      def autoresize_text_area(object_name, method, options = {})
        options[:rows] ||= 3
        options[:cols] ||= 60
        options[:class] = "#{options[:class]}#{options[:class].blank? ? '' : ' '}autoresize_text_area";
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_text_area_tag(options)
      end
      
      alias_method :text_area_autoresize, :autoresize_text_area
      
      def calendar_date_field_tag(object_name, method_name, options = {}, text_field_options = {})
        options[:database_format]  ||= "%Y-%m-%d"
        options[:displayed_format] ||= I18n.t('date.formats')[:long]
        text_field_options[:size]  ||= 18
        
        InstanceTag.new(object_name, method_name, self, options.delete(:object)).to_calendar_select_tag(object_name, options, text_field_options)
      end
      
      def calendar_datetime_field_tag(object_name, method_name, options = {}, text_field_options = {})
        options[:time_select]        = true
        options[:database_format]  ||= "%Y-%m-%d %H:%M:%S"
        options[:displayed_format] ||= I18n.t('time.formats')[:long]
        text_field_options[:size]  ||= 30
        
        InstanceTag.new(object_name, method_name, self, options.delete(:object)).to_calendar_select_tag(object_name, options, text_field_options)
      end
      
      private
        def i18n_label(klass, method)
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
      
      # this method is inspired from Rails v2.3.4, but we add ability to give params on options
      def to_grouped_collection_select_tag(collection, group_method, group_label_method, option_key_method, option_value_method, options, html_options, option_options = {})
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag(
          "select", add_options(option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, value, option_options), options, value), html_options
        )
      end
      
      def to_calendar_select_tag(object_name, options = {}, text_field_options = {})
        options[:default]     ||= object.send(@method_name)
        options[:start_year]  ||= 1900
        options[:end_year]    ||= 2999
        options[:time_select] ||= false
        options[:time_format] ||= 24
        options[:disabled]    ||= false
        
        textfield_value      = I18n.l(options[:default], :format => options[:displayed_format]) rescue options[:default]
        text_field_options   = { :readonly          => true,
                                 'data-calendar-id' => :calendar_displayed_field,
                                 :value             => textfield_value }.merge(text_field_options)
        
        button_action        = "this.up('.calendar_container').down('[data-calendar-id=calendar_field]').value = ''; this.up('.calendar_container').down('[data-calendar-id=calendar_displayed_field]').value = ''"
        button_options       = { :class    => :calendar_cleaner, :title => "Effacer" }
        
        hidden_field_value   = I18n.l(options[:default], :format => options[:database_format]) rescue options[:default]
        hidden_field_options = { :name              => object_name + "[#{@method_name}]",
                                 'data-calendar-id' => :calendar_field,
                                 :disabled          => options[:disabled],
                                 :value             => hidden_field_value }
        
        trigger_options      = { :class => :calendar_trigger }
        
        calendar_options     = "{range       : [#{options[:start_year]},#{options[:end_year]}],
                                 showsTime   : #{options[:time_select]},
                                 timeFormat  : #{options[:time_format]},
                                 ifFormat    : '#{options[:database_format]}',
                                 altIfFormat : '#{options[:displayed_format]}',
                                 disabledIf  : #{options[:disabled]},
                                 showOthers  : true }"
        
        text_field     = text_field_tag("#{@object_name}_displayed_#{@method_name}_for_calendar", nil, text_field_options)
        button         = button_to_function "", button_action, button_options
        hidden_field   = InstanceTag.new(@object_name, @method_name, self, options.delete(:object)).to_input_field_tag("hidden", hidden_field_options)
        trigger        = image_tag("calendar.png", trigger_options)
        calendar_setup = javascript_tag("Calendar.setup(#{calendar_options});")
        
        content_tag(:span, text_field + error_unwrapping(button + hidden_field + trigger + calendar_setup), :class => :calendar_container)
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
          :span, to_collection_select_tag(collection, value_method, text_method, options, select_options.merge(show_select ? {} : { :value => '' })),
          :class => "#{choice_method_name}_select_container",
          :style => show_select ? '' : 'display:none'
        ) +
        content_tag_without_error_wrapping(
          #OPTIMIZE we shouldn't have to manually add the brackets '[]' after the object_name, but the call of 'to_collection_select_tag_with_custom_choice' remove end brackets to the object_name
          :span, InstanceTag.new("#{@object_name}[]", choice_method_name, self, @object).to_input_field_tag("text", text_field_options.merge(show_select ? { :value => '' } : {})) +
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
      
      # this method is inspired from Rails v2.3.4, but we add ability to give params on options
      def grouped_collection_select(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {}, option_options = {})
        @template.grouped_collection_select(@object_name, method, collection, group_method, group_label_method, option_key_method, option_value_method, objectify_options(options), @default_options.merge(html_options), option_options)
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
