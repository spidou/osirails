module PremiaHelper 

	def show_employee_view_button(object, txt = "View current employee")
		if menu_employees.can_view?(current_user) and Employee.can_view?(current_user)	
			link_to( image_tag( "/images/view_16x16.png", :alt => "View", :title => "View" )+" #{txt}", employee_path(object) )		
		end	
	end	

	def show_employee_list_button(txt = "View all employees")
		if menu_employees.can_list?(current_user) and Employee.can_list?(current_user)	
			link_to( image_tag( "/images/list_16x16.png", :alt => "List", :title => "List" )+" #{txt}", employees_path)		
		end	
	end

end
