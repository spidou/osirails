module WatchingsHelper
  
  def watchable_function_time_unity
    options = []
    options << ["Toutes les minutes", WatchingsWatchableFunction::MINUTLY_UNITY]
    options << ["Toutes les heures", WatchingsWatchableFunction::HOURLY_UNITY]
    options << ["Tous les jours", WatchingsWatchableFunction::DAILY_UNITY]
    options << ["Toutes les semaines", WatchingsWatchableFunction::WEEKLY_UNITY]
    options << ["Tous les mois", WatchingsWatchableFunction::MONTHLY_UNITY]
    options << ["Tous les ans", WatchingsWatchableFunction::YEARLY_UNITY]
    options
  end
  
  def watching_new_link(watchable, return_uri)
    return unless watchable.not_watched_by?(current_user) && !watchable.new_record?
    link_to_remote("Surveiller",
                   { :url       => new_watching_path(:watchable_type => watchable.class.name, :watchable_id => watchable.id, :return_uri => return_uri),
                     :update    => "content_popup_box",
                     :method    => 'get',
                     :complete  => "display_popup_box();" },
                   { 'data-icon' => :unwatching })
  end
  
  def watching_edit_link(watchable, return_uri)
    return unless watchable.already_watched_by?(current_user) && !watchable.new_record?
    link_to_remote("Surveiller",
                   { :url       => edit_watching_path(watchable.find_watching_with(current_user.id), :return_uri => return_uri),
                     :update    => "content_popup_box",
                     :method    => 'get',
                     :complete  => "display_popup_box();" },
                   { 'data-icon' => :watching })
  end
  
  def watching_link(watchable)
    watching_edit_link(watchable, url_for(:only_path => true)) || watching_new_link(watchable, url_for(:only_path => true))
  end
  
  def refreshed_watching_link(watchable)
    html = ""
    html << "<span id='watching_#{watchable.class.name.underscore}_#{watchable.id}'>"
    html << watching_link(watchable)
    html << "</span>"
  end
  
  def include_popup_box_headers
    html = []
    html << stylesheet_link_tag('popup_box')
    html << javascript_include_tag('acts_as_watchable/popup')
    html << javascript_include_tag('acts_as_watchable/acts_as_watchable')
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
