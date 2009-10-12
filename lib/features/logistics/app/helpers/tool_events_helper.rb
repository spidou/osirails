module ToolEventsHelper

  ##################################################################
  ########## ALARMS METHODS #######################################
  
  # method that permit to add with javascript a new record of alarm
  def add_alarm_link
    link_to_function "Ajouter une alerte" do |page|
      page.insert_html :bottom, :alarms, :partial => "tool_alarm", :object => Alarm.new
    end  
  end 
  
  # method that permit to remove with javascript a new record of alarm
  def remove_alarm_link(alarm)
    if is_form_view?
      if alarm.new_record?
        link_to_function( "Supprimer", "$(this).up('.alarm').remove()")
      else
        link_to_function( "Supprimer" , "mark_resource_for_destroy(this)") 
      end
    end
  end
  
  def get_delay(alarm)
    value = alarm.humanize_delay[:value]
    unit  = alarm.humanize_delay[:unit]
    unit  = unit.pluralize if value > 1
    "#{value} #{unit}"
  end
  
  def get_delay_value(alarm)
    alarm.humanize_delay[:value]
  end
  
  def get_delay_unit(alarm)
    alarm.humanize_delay[:unit]
  end
end
