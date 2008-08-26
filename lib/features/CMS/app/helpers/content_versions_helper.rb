module ContentVersionsHelper
  def contributor_full_name(content_version)
    content_version.contributor.employee.last_name + " " + content_version.contributor.employee.first_name
  end
  
  
end
