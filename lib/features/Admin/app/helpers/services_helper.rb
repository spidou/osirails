module ServicesHelper
  
  # This method permit to verify if a service have got children or employees
  def show_delete_button(service)
    " &#124; " + link_to("Supprimer", service, {:method => :delete, :confirm => 'Etes vous sûr  ?' }) unless service.employees.size > 0 or service.children.size > 0
  end
  
end