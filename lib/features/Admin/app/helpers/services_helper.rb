module ServicesHelper
  
  # This method permit to verify if a service have got children or employees
  def show_delete_button(service,can_delete)
    " &#124; " + link_to("Supprimer", service , { :method => :delete, :confirm => 'Etes vous sûr  ?' }) if service.can_delete? and can_delete
  end
  
  # This method permit to have a services on <ul> type.
  def show_structured_services(can_edit, can_delete)
    services = Service.find_all_by_service_parent_id
    list = []
    list << "<div class='hierarchic'><ul class=\"parent\">"
    list = get_children(services,list,can_edit, can_delete)
    list << "</ul></div>"
    list 
  end
  
  # This method permit to make a tree for services
  def get_children(services,list,can_edit, can_delete)
    services.each do |service|
      delete_button = show_delete_button(service, can_delete)
      edit_button = link_to("Modifier", { :action => "edit", :id => service } ) if can_edit
      list << "<li class=\"menus\">#{service.name} &nbsp; <span class=\"action\">#{edit_button}#{delete_button}</span></li>"
      if service.children.size > 0
        list << "<ul>"
        get_children(service.children,list,can_edit, can_delete)
        list << "</ul>"
      end
    end
    list
  end
  
  # method to make a day select
  def day_select(id)
    html =  select('shedules[' + id.to_s + ']','day', {"Lundi"=>1  ,"Mardi"=>2  ,"Mercredi"=>3 ,"Jeudi"=>4  , "Vendredi"=>5 ,"Samedi"=> 6 ,"Dimanche"=>7  }, :selected => 1)
  end
end
