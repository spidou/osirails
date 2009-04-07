module ChecklistsHelper
  
  def display_checklists_list(checklists_owner)
    raise ArgumentError, "the 'checklists_owner' argument must be an instance of an acts_as_step class. #{owner}:#{owner.class}" unless checklists_owner.class.respond_to?(:original_step)
    checklists = checklists_owner.original_step.checklists
    unless checklists.empty?
      html = content_tag :h2, "Checklist"
      html << '<div id="checklists">'
      html << render(:partial => 'checklists/checklist', :collection => checklists, :locals => { :checklists_owner => checklists_owner })
      html << '</div>'
    end
  end
  
end
