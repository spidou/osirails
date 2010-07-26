module ChecklistsHelper
  
  def display_environment_checklist_for(end_product)
    render :partial => 'checklists/checklist', :object => Checklist.find_by_name("environment_checklist_for_end_products_in_survey_step"),
                                               :locals => { :end_product => end_product }
  end
  
end
