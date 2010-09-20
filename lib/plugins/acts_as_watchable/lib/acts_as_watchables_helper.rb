module ActsAsWatchablesHelper
  
  def watchable_function_time_unity
    options = []
    options << ["minutes", WatchablesWatchableFunction::MINUTLY_UNITY]
    options << ["Heures", WatchablesWatchableFunction::HOURLY_UNITY]
    options << ["Jours", WatchablesWatchableFunction::DAILY_UNITY]
    options << ["Semaines", WatchablesWatchableFunction::WEEKLY_UNITY]
    options << ["Mois", WatchablesWatchableFunction::MOUNTHLY_UNITY]
    options << ["Année", WatchablesWatchableFunction::YEARLY_UNITY]
    options
  end
  
  def edit_button(object, uri)
    return unless object.can_edit_watchable?(current_user) && !object.new_record?
    text = "Editer la surveillance de cette objet"
    message ||= " #{text}"
    link_to_remote( image_tag( "star_16x16.png",
                    :alt => text,
                    :title => text ),
            :url => edit_acts_as_watchable_path(object.find_watchable_with(current_user.id), {:return_uri => uri}), 
            :update => "content_popup_box", :method => 'get',
            :complete => "display_popup_box();" )
  end
  
  def new_button(object, uri)
    return unless object.can_watch?(current_user) && !object.new_record?
    text = "Surveiller cette objet"
    message ||= " #{text}"
    link_to_remote( image_tag( "disabled_star_16x16.png",
                        :alt => text,
                        :title => text ),
            :url => new_acts_as_watchable_path({:object_type => object.class.name, :object_id => object.id,:return_uri => uri}), 
            :update => "content_popup_box", :method => 'get',
            :complete => "display_popup_box();" )
  end
  
  def display_button(object)
    (edit_button(object, url_for(:only_path => true)) || new_button(object, url_for(:only_path => true)))
  end
  
  def display_env_button(object)
    html = []
    html << "<span  id='span_#{object.class.name}_#{object.id}'>"
    html << display_button(object)
    html << "</span>"
  end
  
  def display_watchable_button(object)
    return unless object.can_watch?(current_user) && !object.new_record?
    #For use without AJAX
    #link_to( image_tag( "disabled_star_16x16.png",
    #                    :alt => text,
    #                    :title => text ),
    #        new_acts_as_watchable_path({:object_type => object.class.name, :object_id => object.id,:return_uri => uri}))
    
    display_env_button(object)
  end
      
  def display_watchable_edit_button(object)
    return unless object.can_edit_watchable?(current_user) && !object.new_record?
    #For use without AJAX
    #link_to( image_tag( "star_16x16.png",
    #                :alt => text,
    #                :title => text ),
    #        :url => edit_acts_as_watchable_path(object.find_watchable_with(current_user.id), {:return_uri => uri}))
    
    display_env_button(object)
  end

  def display_acts_as_watchable_buttons(object)
    html = []
    html << (display_watchable_button(object) || display_watchable_edit_button(object))
  end
  
  def include_popup_box_headers
    html = []
    html << stylesheet_link_tag('popup_box')
    html << javascript_include_tag('popup') 
    html << javascript_include_tag('acts_as_watchables/acts_as_watchables')
    html
  end
  
  def display_popup_menu_actions
    html = []
    html << '<div id="popup_menu_actions">'
    html << link_to_function( image_tag( "cross_16x16.png", :title => hide_menu = 'Fermer la popup', :alt => hide_menu ), 
                          '$("popup_box").popup.hide();')
    html << "</div>"
    html
  end
  
  def display_popup_box_div_for_acts_as_watchable
     html = []
     html << '<div id="popup_box" style="display:none;">'
     html << '<div id="content_popup_box"></div>'
     html << '</div>'
  end
  
end  

