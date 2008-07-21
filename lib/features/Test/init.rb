dependencies = []
conflicts = []
business_objects = ["Document","DocumentGraphique"]
pages = []

f = Osirails::Feature.find_or_create_by_name_and_version("Test","0.1")
f.dependencies = dependencies
f.conflicts = conflicts
f.save

roles_count = Osirails::Role.count
business_objects.each do |bo|
  unless Osirails::Permission.find_all_by_has_permission_type(bo).size == roles_count
    Osirails::Role.find(:all).each do |role|
      Osirails::Permission.find_or_create_by_has_permission_type_and_role_id(bo,role.id)
    end
  end 
end