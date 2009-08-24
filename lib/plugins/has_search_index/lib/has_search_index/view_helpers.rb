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
      errors = check_arguments(model, attributes)
      attributes.delete_if {|attribute| errors[:wrong_attributes].include?(attribute) or errors[:wrong_model]}        # filter attributes according to errors
      
      html =  form_remote_tag( :url => '/search_index/update', :update => "ajax_holder_content", :before => "javascript:prepare_ajax_holder()", :loaded => "javascript:ajax_holder_loaded()" )
      html << "<p>"
      html << "<input type='hidden' name='contextual_search[errors]' value='#{errors.to_yaml}'/>" # errors_hash
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
    
    private
    
      # Method to verify arguments
      # return an hash containing the errors for each attributes:
      # ==> :wrong_model : if false no errors (default) , if true it won't be possible to perform a contextual search with the current configuration
      # ==> :wrong_attributes : an array of attributes 
      #
      def check_arguments(model, attributes)
        result = {:wrong_model => false, :wrong_attributes => []}
        if HasSearchIndex::MODELS.include?(model)       
          attributes.each do |attribute|
            object = model.constantize.new
            attribute.split(".").each do |element|
              break if element == "*"  # go to the next attribute if '*' is reached
              if object.search_index[:attributes].merge(object.search_index[:additional_attributes]).include?(element) or object.search_index[:relationships].include?(element.to_sym)
                object = element.classify.constantize.new unless element == attribute.split(".").last
              else
                result[:wrong_attributes] << attribute
                type       = (element == attribute.split(".").last)? "attribute" : "relationship"
                error_mess = "[#{DateTime.now}](has_search_index) contextual_search > #{type} '#{element}' in '#{attribute}' is undefined.\nYou should modify the configuration of 'has_search_index' in the class '#{model}', or the configuration of the contextual search"
                RAILS_ENV == "production" ? logger.error(error_mess) : raise(error_mess)
                break  
              end
            end
          end
        else
          result[:wrong_model] = true
        end
        result
      end
    
  end
end

# Set it all up.
if Object.const_defined?("ActionView")
  ActionView::Base.send :include, HasSearchIndex::ViewHelpers
end
