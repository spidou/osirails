module ContentVersionsHelper
  
  # This method permit to have full_name contributor
  def contributor_full_name(content_version)
    unless content_version.contributor.employee.nil?
    content_version.contributor.employee.last_name + " " + content_version.contributor.employee.first_name
    else
      content_version.contributor.username
    end
  end
    
end
