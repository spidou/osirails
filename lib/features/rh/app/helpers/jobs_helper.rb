module JobsHelper

  def show_edit_button(job,txt="")
		if controller.can_edit?(current_user) and Job.can_edit?(current_user)	
			link_to("#{image_tag("/images/edit_16x16.png", :alt => "Modifier" , :title => "Modifier" )} #{txt}",edit_job_path(job))	
		end	
	end
	
	def show_add_button(txt="")
		if controller.can_add?(current_user) and Job.can_add?(current_user)
			link_to("#{image_tag("/images/add_16x16.png", :alt => "Ajouter", :title => "Ajouter" )} #{txt}", new_job_path)
		end
	end

	def show_view_button(job,txt="")
		if controller.can_view?(current_user) and Job.can_view?(current_user)
			link_to("#{image_tag("/images/view_16x16.png", :alt => "D&eacute;tails", :title => "D&eacute;tails")} #{txt}", job_path(job))
		end
	end

	def show_delete_button(job,txt="")
		if controller.can_delete?(current_user) and Job.can_delete?(current_user)
			link_to("#{image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer")} #{txt}", job, {:method => :delete , :confirm => 'Etes vous s&ucirc;r ?' } )
		end	
	end

end
