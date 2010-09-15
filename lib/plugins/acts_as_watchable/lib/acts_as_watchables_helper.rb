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
      
  def display_watchable_button(object, uri)
    return unless object.can_watch?(current_user) && !object.new_record?
    text = "Surveiller cette objet"
    message ||= " #{text}"
    link_to( image_tag( "disabled_star_16x16.png",
                        :alt => text,
                        :title => text ),
            new_acts_as_watchable_path({:object_type => object.class.name, :object_id => object.id,:return_uri => uri}))
  end
      
  def display_watchable_edit_button(object, uri)
    return unless object.can_edit_watchable?(current_user) && !object.new_record?
    text = "Editer la surveillance de cette objet"
    message ||= " #{text}"
    link_to( image_tag( "star_16x16.png",
                    :alt => text,
                    :title => text ),
            edit_acts_as_watchable_path(object.find_watchable_with(current_user.id), {:return_uri => uri}))
  end

  def display_acts_as_watchable_buttons(object)
    html = []
    html << (display_watchable_button(object, url_for(:only_path => true)) || display_watchable_edit_button(object, url_for(:only_path => true)))
  end

end  

