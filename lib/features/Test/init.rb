require 'yaml'
yaml = YAML.load(File.open('config.yml'))
$feature = yaml['feature']
dependencies = yaml['dependencies']
conflicts = yaml['conflicts']
business_objects = yaml['business_objects']
pages = yaml['pages']

# This array store all pages in order than they will be displayed
$page_table = []


#Test of dependencies for this feature
dependences_hash = []
feature = Osirails::Feature.find_or_create_by_name_and_version($feature["name"], $feature["version"])
dependencies.each_pair do |key,value|
  dependences_hash << {:name => key, :version => value} 
end
feature.dependencies = dependences_hash
feature.save


#Test of dependencies for this feature
conflicts_hash = []
feature = Osirails::Feature.find_or_create_by_name_and_version($feature["name"], $feature["version"])
conflicts.each_pair do |key,value|
  conflicts_hash << {:name => key, :version => value}
end
feature.conflicts = conflicts_hash
feature.save


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
  pages.each_pair do |key,value|
    p = Osirails::Page.find_by_name(key)
    unless p.nil?
      unless Osirails::PagePermission.find_all_by_page_id(p.id).size == roles_count
        Osirails::Role.find(:all).each do |role|
          if Osirails::PagePermission.find_by_page_id_and_role_id(p.id, role.id).nil?
            Osirails::PagePermission.create(:page_id => p.id,:role_id =>role.id)
          end
        end
      end
    end
    unless value["children"].nil?
      page_verification(value["children"])
    end
  end
end

page_verification(pages)


#Test of verification of page
def page_creation(pages,parent_name)
  pages.each_pair do |key,value|
    $page_table << {  :name => key, :title_link => value["title_link"], :description_link => value["description_link"], :url => value["url"], :parent => parent_name}
    unless value["children"].nil?
      page_creation(value["children"], key)
    end
  end
end

page_creation(pages,"")


$page_table.each do |page|
  parent_page = Osirails::Page.find_by_name(page[:parent])
  unless Osirails::Page.find_by_name(page[:name])
    if parent_page.nil?
      Osirails::Page.create(:title_link =>page[:title_link], :description_link => page[:description_link], :url => page[:url], :name => page[:name])
    else
      Osirails::Page.create(:title_link =>page[:title_link], :description_link => page[:description_link], :url => page[:url], :name => page[:name], :parent_id =>parent_page.id )
    end
  end
end