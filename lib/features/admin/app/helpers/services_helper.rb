module ServicesHelper
  
  # This method permit to verify if a service have got children or employees
  def show_service_delete_button(service,txt="Delete current service")
    if Service.can_delete?(current_user)
      if service.can_be_destroyed?
        link_to(image_tag("delete_16x16.png", :title => "Delete", :alt => "Delete")+" #{txt}", service , { :method => :delete, :confirm => 'Êtes vous sûr?' }) 
      else
        image_tag("delete_disable_16x16.png", :alt => "Delete", :title => "Delete")+" #{txt}"
      end
    end
  end
  
  # This method test permission for add_button
  def new_service_link_with_parent(service,txt="")
    if Service.can_add?(current_user)
			link_to(image_tag("add_16x16.png", :title => "Add", :alt => "Add")+" #{txt}", new_service_path(:service_id => service.id))
    end
  end
  
  # This method permit to have a services on <ul> type.
  def show_structured_services(services)
    list = []
    list << "<div class='hierarchic'><ul class=\"parent\">"
    list = get_children_services(services,list)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for services
  def get_children_services(services,list)
    services.each do |service|
      delete_button = delete_service_link(service,:link_text => "")
      show_button = service_link(service,:link_text => "")
      edit_button = edit_service_link(service,:link_text => "")
			add_button = new_service_link_with_parent(service,"")
      list << "<li class=\"menus\">#{service.name} &nbsp; <span class=\"action\">#{show_button} #{add_button} #{edit_button}#{delete_button}</span></li>"
      if service.children.size > 0
        list << "<ul>"
        get_children_services(service.children,list)
        list << "</ul>"
      end
    end
    list
  end
  
  # method to make a day select
  def day_select(id)
    # .sort {|a,b| a[1]<=>b[1]} #=> perform a sort by VALUE and not by KEY
    # Time class located in overrides.rb
    html =  select('period[' + id.to_s + ']','day', Time::DAYS.sort {|a,b| a[1]<=>b[1]}, :selected => 1)
  end
  
  # method to responsables of the service 
  def responsable_find(ids)
    responsables_list = ""
    ids.each do |responsable_id|
      responsables_list << ", " if responsables_list != ""
      responsables_list << link_to( Employee.find(responsable_id).fullname, employee_path(responsable_id))
    end
    
    return "<label>Responsable hierachique :</label> \n" + responsables_list  if ids.size==1
    return "<label>Responsables hierachiques :</label> \n" + responsables_list if ids.many?
    return "" if ids.size==0
  end
  
  # method choose the good title for members
  def members(ids)
    return "<label>Membre :</label>" if ids.size==1
    return "<label>Membres :</label>" if ids.many? 
    return "" if ids.size==0
  end
  
  # method to display textfield where the user puts his shedules
  def display_shedule_text_field(moment,tabindex)
    html = text_field_tag( moment + '_start[hour]',nil,:size=> 1,:maxlength =>2,:class => "disable-stylesheet-width",:tabIndex => tabindex.to_s, :id => tabindex.to_s,:onkeyup=>"time(this);") + " H "
    tabindex+=1
    html += text_field_tag( moment + '_start[minute]',nil,:size=> 1,:maxlength =>2,:class => "disable-stylesheet-width",:tabindex => tabindex.to_s, :id => tabindex.to_s, :onkeyup=>"time(this);") + " - " 
    tabindex+=1
    html += text_field_tag( moment + '_end[hour]',nil,:size=> 1,:maxlength =>2,:class => "disable-stylesheet-width",:tabindex => tabindex.to_s, :id => tabindex.to_s, :onkeyup=>"time(this);") + " H "
    tabindex+=1
    html += text_field_tag( moment + '_end[minute]',nil,:size=> 1,:maxlength =>2,:class => "disable-stylesheet-width",:tabindex => tabindex.to_s, :id => tabindex.to_s, :onkeyup=>"time(this);") 
    html
  end
  
  # method to convert a foat to a string showing hours and minutes
  def to_hour(float)
    unless float.nil?
      float = float.to_f
      formated_hour = float.floor.to_s + " H "
      min = (float-float.floor).minutes.to_i
      formated_hour += min == 0 ? min.to_s + "0": min.to_s 
    else
      formated_hour = " H "
    end
    
  end
  def days_sort (schedules)
    tab = []
    i=1
    week = Time::DAYS
    unless schedules == []
      while( tab.size<=7 and i<=7)
        schedules.each do |s|
          if week[s.day]==i
            tab[i] = s 
          end
        end
        i += 1
      end
    end  
    return tab
  end
  
  # method to format the values hash to a string that will be used by the controller to create or update schedules
  def schedule_to_s(hash)
    string_schedule = ""
    string_schedule += to_hour(hash['morning_start'])+ "|"
    string_schedule += to_hour(hash['morning_end'])+ "|"
    string_schedule += to_hour(hash['afternoon_start'])+ "|"
    string_schedule += to_hour(hash['afternoon_end'])+ "|"
    return string_schedule
  end
  
  # method to test if all schedules values are nulls
  def schedules_empty?(schedules)
    tab = []
    schedules.each do |schedule|
      tab << schedule.morning_start
      tab << schedule.morning_end
      tab << schedule.afternoon_start
      tab << schedule.afternoon_end
    end
    return tab.all_values_nil?
  end
  
  def days_group(days_array)
    tab = [""]
    actual = 1
    tab << days_array[1]
    first = 1
    ind = 2 
    while ind <= 7
      equal = true
      equal = false if days_array[ind - 1].morning_start != days_array[ind].morning_start
      equal = false if days_array[ind - 1].morning_end != days_array[ind].morning_end
      equal = false if days_array[ind - 1].afternoon_start != days_array[ind].afternoon_start
      equal = false if days_array[ind - 1].afternoon_end != days_array[ind].afternoon_end
      if equal == true
        tab[first].day += "|" + Time::R_DAYS[ind]
      elsif  !days_array[ind].morning_start.nil? and !days_array[ind].morning_end.nil? and !days_array[ind].afternoon_start.nil? and !days_array[ind].afternoon_end.nil?
        tab << days_array[ind]
        first += 1
      end
      ind+=1
    end
    tab
  end
  
  # method to get a array from a params hash
  def format_param(params_schedules)
    tab = []
    params_schedules.sort.each do |value|
      tab[value[0].to_i] = value[1]
    end
    return tab
  end
  
  def period(chaine)
    tab = chaine.split("|")
    if tab.many?
      chaine = "Du " + tab[0] + " au " + tab.last  if tab.many?
    else
      chaine = "Le " + chaine
    end
    return chaine
  end
  
end
