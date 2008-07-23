dependencies = []
conflicts = []
business_objects = ["Document","DocumentGraphique"]
pages = [{:name => "admin", :child => [{:name => "users", :child => [:name =>"gestion"]},{:name => "roles"}, {:name => "features"}, {:name => "CMS"}]}]
$page_table = []

#Test of dependencies for this feature
f = Osirails::Feature.find_or_create_by_name_and_version("Test","0.1")
f.dependencies = dependencies
f.conflicts = conflicts
f.business_objects = business_objects
f.save

roles_count = Osirails::Role.count
#Test if all permission for all business objects are present
business_objects.each do |bo|
  unless Osirails::BusinessObjectPermission.find_all_by_has_permission_type(bo).size == roles_count
    Osirails::Role.find(:all).each do |role|
      Osirails::BusinessObjectPermission.find_or_create_by_has_permission_type_and_role_id(bo, role.id)
    end
  end 
end

#Test if all permission for all pages are present
def page_verification(pages)
  roles_count = Osirails::Role.count
  pages.each do |page|
    p = Osirails::Page.find_by_name(page[:name])
    unless p.nil?
      unless Osirails::PagePermission.find_all_by_page_id(p.id).size == roles_count
        Osirails::Role.find(:all).each do |role|
          if Osirails::PagePermission.find_by_page_id_and_role_id(p.id, role.id).nil?
            Osirails::PagePermission.create(:page_id => p.id,:role_id =>role.id)
          end
        end
      end
    end
    unless page[:child].nil?
      page_verification(page[:child])
    end
  end
end

page_verification(pages)

#Test of verification of page
def page_creation(pages,parent_name)
  pages.each do |page| 
   $page_table << {:name =>page[:name], :parent =>parent_name}
    unless page[:child].nil?
      page_creation(page[:child],page[:name])
    end
  end
end

page_creation(pages,"")

$page_table.each do |page|
  parent_page = Osirails::Page.find_by_name(page[:parent])
  unless Osirails::Page.find_by_name(page[:name])
    if parent_page.nil?
      Osirails::Page.create(:name => page[:name])
    else
      Osirails::Page.create(:name => page[:name],  :parent_id => parent_page.id)
    end
  end
end
