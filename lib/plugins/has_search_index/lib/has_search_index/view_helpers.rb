module HasSearchIndex
  module ViewHelpers
    # Method to display contestual search into secondary menu
    # you mays give two arguments:
    # model => the model where to perform the search
    # attributes => an array of all attributes to add as criterion to perform the search
    #
    # You can perform search in every configured attributes of the given Model
    # ==== Example
    #   class User < ActiveRecord::Base
    #     has_search_index :only_attributes => ["username", "enabled", "last_connection", "last_activity"]
    #   end
    #
    #   contextual_search("User", [ "username", "last_activity" ])
    #
    # You can perform search in relationships (or sub-models) of the given Model
    # ==== Example
    #   contextual_search("User", [ "username", "roles.name" ])
    #
    # You can use * to search in all configured attributes of the given Model or Relationship
    # ==== Example
    #   contextual_search("User", [ "*", "roles.*" ])
    #
    # You can perform search in relationships of the given Model, and in relationships of relationships (as deeply as you want)
    # ==== Example
    #   contextual_search("Employee", ["numbers.number_type.name"])
    #
    def contextual_search(model, attributes)
      html =  form_remote_tag( :url => '/search_index/update', :update => "ajax_holder_content", :before => "javascript:prepare_ajax_holder()", :loaded => "javascript:ajax_holder_loaded()" )
      html << "<p>"
      html << "<input type='hidden' name='contextual_search[model]' value='#{model}'/>"
      html << "<input type='hidden' name='contextual_search[options]' value='#{attributes.to_yaml}'/>"
      focus = "if(this.value=='Rechercher'){this.value='';}"
      blur  = "if(this.value==''){this.value='Rechercher'}"
      html << text_field_tag("contextual_search[value]",'Rechercher',:id => 'contextual_search', :onfocus => focus, :onblur => blur)
      html << "<button type=\"submit\" class=\"contextual_search_button\"></button>"
      html << "</p>"
      html << "</form>"
      
      add_contextual_menu_item(:contextual_search, true, html)
    end
  end
end

# Set it all up.
if Object.const_defined?("ActionView")
  ActionView::Base.send :include, HasSearchIndex::ViewHelpers
end
