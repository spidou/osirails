require 'integrated_search_helper' # remove that line if trying to externalize and make a plugin for 'context-menu'

require 'action_view/helpers/tag_helper'
require 'action_view/helpers/form_tag_helper'

module ActionView
  module Helpers
    
    class ContextMenu
      attr_accessor :template
      
      def initialize(template, &block)
        raise ArgumentError, "Missing block" unless block_given?
        
        @template = template
        @template.concat("<ul>")
        yield self
        @template.concat('</ul>')
      end
      
      def title(content)
        @template.content_tag(:li, content, :class => :title) unless content.blank?
      end
      
      def entry(content)
        @template.content_tag(:li, content, :class => :entry) unless content.blank?
      end
      
      def submenu(*args, &block)
        raise ArgumentError, "Missing block" unless block_given?
        
        title = @template.link_to(args.first, {}, :class => :submenu, :href => "#")
        
        content = "<ul>"
        @template.capture(&block).split("\n").each { |c| content << self.entry(c) unless c.blank? }
        content << "</ul>"
        
        if content != "<ul></ul>"
          @template.concat( @template.content_tag(:li, title + content, :class => :folder) )
        end
      end
    end
    
    # Makes a HTML item selectable by right click, associated with a ruby object and a context menu available with 
    # left click. Must be called into a HTML item that accepts a checkbox inside as it is delivered with a checkbox
    # whose name (indicating the ruby object class name) and value (the object id) are sended.
    #
    # ==== Call example
    #        
    #   <table>
    #     <thead>
    #       <tr>
    #         <th>#</th>
    #         <th>First name</th>
    #       </tr>
    #     </thead>
    #     <tbody>
    #       <% for employee in @employees %>
    #         <tr class="employee_table_row">
    #           <td><%= context_menu(employee, "employee_table_row") %>
    #           <td><%= employee.first_name %></td>
    #         </tr>
    #       <% end %>
    #     </tbody>
    #   </table>
    #
    # ==== Context menu template convention
    #
    #   The template is searched in view paths with the following priority order:
    #
    #      1. Option passed in the method call
    #        # => <%= context_menu(<object>, <html_class>, :<single|multiple>_selection_template) => <path> %>
    #       
    #        Example:
    #        # => <%= context_menu(employee.service, "service", :multiple_selection_template => "employees/custom_multiple_selection_template") %>
    #    
    #      2. At the controller level and specific to a model
    #        # => "<controller_folder_name>/<underscored_object_class_name>_context_menu_<'single'|'multiple'>_selection"
    #    
    #        Example:
    #        # => "employees/service_context_menu_single_selection"
    #    
    #      3. At the model level
    #        # => "shared/<underscored_object_class_name>_context_menu_<'single'|'multiple'>_selection"
    #    
    #        Example:
    #        # => "shared/service_context_menu_multiple_selection"
    #    
    #      4. Default template
    #        # => "shared/context_menu_<'single'|'multiple'>_selection"
    #    
    #        Example:
    #        # => "shared/context_menu_single_selection"
    #
    #
    # ==== Additional options
    #   
    #   :allow_multiple_selection 
    #     True by default, this option permit to allow multiple selection of items with the same HTML class, with
    #     checkbox click or the help of CTRL and SHIFT keys. If false, one item is selected at the same time.
    #
    #   :display_checkbox
    #     True by default, this option permit to display the checkbox selection.
    #
    def context_menu(object, selectable_item_html_class, options = {})
      options = { :display_checkbox => true,
                  :allow_multiple_selection => true }.merge(options)
      
      @context_menu_classes ||= []
      klass, html = object.class, ""
      
      #OPTIMIZE those three following addition in html are repeated after each call of context_menu whereas a simple call for these three are enough
      # for a same object. Conditions were deleted because it caused trouble when Ajax was used.
      
#      unless @context_menu_classes.include?(klass)
#        html << javascript_tag("new ContextMenu('#{context_menu_path(:authenticity_token => form_authenticity_token)}', '#{selectable_item_html_class}')")
#        html << hidden_field_tag("#{klass.name.underscore}_single_selection_template", options[:single_selection_template]) if options[:single_selection_template]
#        html << hidden_field_tag("#{klass.name.underscore}_multiple_selection_template", options[:multiple_selection_template]) if options[:multiple_selection_template]
#        @context_menu_classes << klass
#      end
      
      html << javascript_tag("new ContextMenu('#{context_menu_path(:authenticity_token => form_authenticity_token)}', '#{selectable_item_html_class}')")
      html << hidden_field_tag("#{klass.name.underscore}_single_selection_template", options[:single_selection_template]) if options[:single_selection_template]
      html << hidden_field_tag("#{klass.name.underscore}_multiple_selection_template", options[:multiple_selection_template]) if options[:multiple_selection_template]
      # end OPTIMIZE
      
      html << check_box_tag("#{object.class.name.underscore}_ids[]", object.id, false,
                            { :id => nil,
                              :class => options[:allow_multiple_selection] ? nil : 'context-menu-single-selection',
                              'data-context-menu' => 1,
                              :style => options[:display_checkbox] ? nil : "display:none" })
      html
    end
    
    # Creates a link to toggle the entire context menu selectable items
    #
    def toggle_selectable_items_link(name, selectable_items_html_class)
      link_to_function name, "toggleSelectableItems('#{selectable_items_html_class}')"
    end
    
    # Displays the context menu
    #
    #   - Use the 'entry' ContextMenu method to add a context menu entry
    #   - Use the 'submenu' ContextMenu method to add a context menu entry with submenu
    #   
    #   Example:
    #
    #     <% display_context_menu do |c| %>
    #
    #       <%= c.entry employee_link %> 
    #       <%= c.entry edit_employee_link %> 
    #       <%= c.entry delete_employee_link %> 
    #
    #       <% c.submenu "History" do %>
    #
    #         <%= employee_salaries_link %>
    #         <%= employee_premia_link %>
    #         <%= employee_leaves_link %>
    #
    #       <% end%> 
    #
    #     <% end %>
    #
    #     # => Show employee
    #          Edit employee
    #          Delete employee
    #          History
    #          |___ Salaries
    #          |___ Premia
    #          |___ Leaves
    #    
    def display_context_menu(&block)
      raise ArgumentError, "Missing block" unless block_given?
      
      ContextMenu.new(@template, &block)
    end
    
    private
      #### move these 2 following methods if trying to externalize and make a plugin for 'context-menu'
      
      ## This method override an original behaviour (integrated_search_helper.rb on has_search_index plugin)
      #  to automatically add the context-menu into auto-generated table from has_search_index.
      #  This behaviour can be disabled by setting @hide_selector_column at true in the controller
      def query_thead_tr_with_context_menu(content)
        return query_thead_tr_without_context_menu(content) if @hide_selector_column
        
        helper = "query_thead_tr"
        content = content_tag(:th, toggle_selectable_items_link(image_tag('confirm_16x16.png'), @page_model.underscore)) + content # add th element at first
        
        override_for(helper) ? send(override_for(helper), content) : content_tag(:tr, content)
      end
      alias_method_chain :query_thead_tr, :context_menu
      
      ## same as #query_thead_tr_with_context_menu
      def query_tr_with_context_menu(content)
        helper = "query_tr"
        html_class = "#{@page_model.underscore}_tr"
        style = @hide_selector_column == true ? "display:none" : ""
        
        content = content_tag(:td, context_menu(@query_object, html_class), :class => :selector, :style => style) + content # add td element at first
        override_for(helper) ? send(override_for(helper), content) : content_tag(:tr, content, :class => html_class)
      end
      alias_method_chain :query_tr, :context_menu
      
      ## same as #query_thead_tr_with_context_menu
      # override that helper method to add 1 to colspan attribute ( eg. selector column )
      #
      def query_group_td_with_context_menu(group_by, columns)
        return query_group_td_without_context_menu(group_by, columns) if @hide_selector_column
        
        helper = "query_group_td"
        content = query_group_td_content(group_by)
        override_for(helper) ? send(override_for(helper), content) : content_tag(:td, content, :colspan => columns.size + 1, :class => 'group')
      end
      alias_method_chain :query_group_td, :context_menu
  end
end

ActionView::Base.send :include, ActionView::Helpers
