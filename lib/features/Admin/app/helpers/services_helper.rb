module ServicesHelper
  
  # This method permit to verify if a service have got children or employees
  def show_delete_button(service)
    " &#124; " + link_to("Supprimer", service, {:method => :delete, :confirm => 'Etes vous sûr  ?' }) unless service.employees.size > 0 or service.children.size > 0
  end

  def display_menu(value)
    link_to_function "Caché", update_page { |service| service.visual_effect(:toggle_appear, value) }
  end
  
end
