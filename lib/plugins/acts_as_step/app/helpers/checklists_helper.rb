module ChecklistsHelper
  
  def display_environment_checklist_for(product)
    render :partial => 'checklists/checklist', :object => Checklist.find_by_name("environment_checklist_for_products_in_survey_step"),
                                               :locals => { :product => product }
  end
  
end
