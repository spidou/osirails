module EmployeesQuery

  ################################
  ##  integrated search helpers ##
  ################################
  
  def query_td_content_for_fullname_in_employee
    link_to(@query_object.fullname, employee_path(@query_object))
  end
  
  def query_td_content_for_numbers_number_in_employee
    display_full_phone_number(@query_object.numbers.visibles.first) if @query_object.numbers.visibles.first
  end
  
  def query_group_td_content_in_employee(group_by)
    content_tag(:span, :class => 'not-collapsed', :onclick => "toggleGroup(this);") do
      group_by.map{ |n| "#{ employee_group_translation(n[:attribute]) } #{ content_tag(:span, n[:value], :style => 'color:#555;') }" }.to_sentence
    end
  end
  
  # TODO i18n
  def employee_group_translation(attr)
    tr = {'last_name' => 'de la famille', 'service.name' => 'dans le service'}
    return tr[attr]
  end
end
