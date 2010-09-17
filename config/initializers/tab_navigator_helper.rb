require 'action_view/helpers/tag_helper'
require 'action_view/helpers/form_tag_helper'

module ActionView
  module Helpers
    
    # Generates a full and ready-to-used tab navigator based on TabNavigator
    # javascript class.
    # 
    # ==== Examples
    # 
    #   <% tab_navigator :customer_nav do |t| %>
    #     <% t.nav_buttons do %>
    #       <%= t.tab :informations,    "Informations", :selected => true %>
    #       <%= t.tab :establishments,  "Establishments" %>
    #     <% end %>
    #     
    #     # put your code here
    #     
    #     <% t.content_for :informations do %>
    #       # put your code here
    #     <% end %>
    #     <% t.content_for :establishments do %>
    #       # put your code here
    #     <% end %>
    #   <% end %>
    # # => <ul id="customer_nav" class="tab_nav">
    # #      <li tab="informations" class="selected"><a href="/current_path/?customer_nav=informations" onclick="return false;">Informations</a></li>
    # #      <li tab="establishments" class="selected"><a href="/current_path/?customer_nav=establishments" onclick="return false;">Establishments</a></li>
    # #    </ul>
    # #    
    # #    #code
    # #    
    # #    <div tab="informations" rel="customer_nav" class="content_nav">#code</div>
    # #    <div tab="establishments" rel="customer_nav" class="content_nav">#code</div>
    # #    
    # #    <script type="text/javascript">
    # #      //<![CDATA[
    # #        var customer_nav = new TabNavigator('customer_nav', {})
    # #      //]]>
    # #    </script>
    #
    #
    # Many tab navigators can be nested in order to link them together
    # 
    #   <% tab_navigator :customer_nav do |t| %>
    #     <% t.nav_buttons do %>
    #       <%= t.tab :informations, "Informations", :selected => true %>
    #     <% end %>
    #     
    #     <% t.content_for :informations do %>
    #          
    #       <% tab_navigator :child_nav, :parent => t do |c| %>
    #         <% t.nav_buttons do %>
    #           <%= t.tab :establishments, "Establishments", :selected => true %>
    #         <% end %>
    #         
    #         <% t.content_for :establishments do %>
    #           # put your code here
    #         <% end %>
    #       <% end %>
    #       
    #     <% end %>
    #   <% end %>
    # # => <ul id="customer_nav" class="tab_nav">
    # #      <li tab="informations" class="selected"><a href="/current_path/?customer_nav=informations" onclick="return false;">Informations</a></li>
    # #    </ul>
    # #    
    # #    <div tab="informations" rel="customer_nav" class="content_nav">
    # #      
    # #      <ul id="child_nav" class="tab_nav">
    # #        <li tab="establishments" class="selected"><a href="/current_path/?customer_nav=informations&child_nav=establishments" onclick="return false;">Establishments</a></li>
    # #      </ul>
    # #      
    # #      <div tab="establishments" rel="child_nav" class="content_nav">#code</div>
    # #      
    # #      <script type="text/javascript">
    # #        //<![CDATA[
    # #          var customer_nav = new TabNavigator('customer_nav', {})
    # #        //]]>
    # #      </script>
    # #    
    # #    </div>
    # #    
    # #    <script type="text/javascript">
    # #      //<![CDATA[
    # #        var customer_nav = new TabNavigator('customer_nav', {})
    # #      //]]>
    # #    </script>
    #
    # You can pass javascript options to the TabNavigator javascript class
    #
    #   <% tab_navigator :nav, javascript_options => { :can_unfold_all => true, :select => "'last'" } %>
    # # => <script type="text/javascript">
    # #      //<![CDATA[
    # #        var nav = new TabNavigator('nav', {can_unfold_all:true, select:'last'})
    # #      //]]>
    # #    </script>
    #
    def tab_navigator(name, *args, &block)
      raise ArgumentError, "Missing block" unless block_given?
      raise ArgumentError, "name expected to be a Symbol or a String" unless name.is_a?(Symbol) or name.is_a?(String)
      
      options = args.extract_options!
      
      TabNavigator.new(name, @template, options, &block)
    end
    
    class TabNavigator
      attr_accessor :name, :template, :parent, :selected_tab
      
      def initialize(name, template, options = {}, &block)
        raise ArgumentError, "Missing block" unless block_given?
        @name, @template, @parent = name, template, options.delete(:parent)
        
        javascript_options = "{}"
        javascript_options = @template.send(:options_for_javascript, options[:javascript_options]) if options[:javascript_options]
        
        yield self
        @template.concat(@template.javascript_tag("var #{@name} = new TabNavigator('#{@name}', #{javascript_options})"), block.binding)
      end
      
      def nav_buttons(&block)
        raise ArgumentError, "Missing block" unless block_given?
        
        @template.concat("<ul id=\"#{name}\" class=\"tab_nav\"", block.binding)
        yield self
        @template.concat('</ul>', block.binding)
      end
      
      def tab(tab_name, title, *args)
        tab_name = tab_name.to_s
        options = args.extract_options!
        
        options.update(:tab => tab_name)
        
        options[:class] ||= ""
        options[:class] << " selected" if options.delete(:selected)
        options[:class] << " disabled" if options.delete(:disabled)
        options[:class] << " hidden"   if options.delete(:hidden)
        options[:class].strip!
        
        @selected_tab ||= tab_name if options[:class].include?("selected")
        
        if @template.params[@name]
          if @template.params[@name] == tab_name
            options[:class] << " selected" unless options[:class].include?("selected")
            @selected_tab = tab_name
          else
            options[:class].gsub!("selected", "")
          end
        end
        
        if options[:class].include?("disabled")
          url_params = "#"
        else
          url_params = @template.params.merge(@name => tab_name)
          
          current = @parent
          while current
            url_params.update(current.name => current.selected_tab)
            current = current.parent
          end
        end
        
        @template.content_tag :li, options do
          @template.link_to(title, url_params, :onclick => "return false;")
        end
      end
      
      def content_for(tab_name, *args, &block)
        raise ArgumentError, "Missing block" unless block_given?
        tab_name = tab_name.to_s
        
        options = args.extract_options!
        options.update(:tab => tab_name, :rel => @name)
        options[:class] = "content_nav #{options[:class]}"
        options[:class] << " selected" if tab_name == @selected_tab
        
        @template.concat("<div tab=\"#{tab_name}\" rel=\"#{@name}\" class=\"#{options[:class]}\">", block.binding)
        yield self
        @template.concat('</div>', block.binding)
      end
      
    end
    
  end
end

ActionView::Base.send :include, ActionView::Helpers
