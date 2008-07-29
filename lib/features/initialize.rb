def init(yaml, config, path)
  
  # Load every file in the app directory
  controller_path = File.join(path, 'app', 'controllers')
  $LOAD_PATH << controller_path
  Dependencies.load_paths << controller_path
  config.controller_paths << controller_path
  model_path = File.join(path, 'app', 'models')
  $LOAD_PATH << model_path
  Dependencies.load_paths << model_path
  config.controller_paths << model_path
  ActionController::Base.append_view_path(path + '/app/views/')
  $LOAD_PATH << File.join(path, 'app', 'helpers')
  

  # These variables store the feature's configuration from his config.yml file 
  name = yaml['name']
  version = yaml['version']
  dependencies = yaml['dependencies']
  conflicts = yaml['conflicts']
  business_objects = yaml['business_objects']
  menus = yaml['menus']

  # This array store all menus in order than they will be displayed
  $menu_table = []
   
  feature = Feature.find_or_create_by_name_and_version(name, version)

  #Test of dependencies for this feature
  dependencies_hash = []
  unless dependencies.nil?
    dependencies.each_pair do |key,value|
      dependencies_hash << {:name => key, :version => value}
    end
  end
  feature.dependencies = dependencies_hash
  feature.save

  #Test of conflicts for this feature
  conflicts_hash = []
  unless conflicts.nil?
    conflicts.each_pair do |key,value|
      conflicts_hash << {:name => key, :version => value}
    end
  end
  feature.conflicts = conflicts_hash
  feature.save
  
  #Test of business Objects
  business_objects_array =  []
  unless business_objects.nil?
    business_objects.each do |business_object|
      business_objects_array << [business_object]
    end
    feature.business_objects = business_objects_array
    feature.save
  end

  roles_count = Role.count
  #Test if all permission for all business objects are present
  unless business_objects.nil?
    business_objects.each do |bo|
      unless BusinessObjectPermission.find_all_by_has_permission_type(bo).size == roles_count
        Role.find(:all).each do |role|
          BusinessObjectPermission.find_or_create_by_has_permission_type_and_role_id(bo, role.id)
        end
      end  
    end
  end

  #Test if all permission for all menus are present
  def menus_permisisons_verification(menus)
    roles_count = Role.count
    menus.each_pair do |key,value|
      p = Menu.find_by_name(key)
      unless p.nil?
        unless MenuPermission.find_all_by_menu_id(p.id).size == roles_count
          Role.find(:all).each do |role|
            if MenuPermission.find_by_menu_id_and_role_id(p.id, role.id).nil?
              MenuPermission.create(:menu_id => p.id,:role_id =>role.id)
            end
          end
        end
      end
      unless value['children'].nil?
        menus_permisisons_verification(value['children'])
      end
    end
  end

  menus_permisisons_verification(menus)


  # This method insert in $menu_table all feature's menus
  def menu_insertion(menus,parent_name)
    menus.each_pair do |key,value|
      $menu_table << {  :name => key, :title_link => value["title_link"], :description_link => value["description_link"], :url => value["url"], :parent => parent_name}
      unless value["children"].nil?
        menu_insertion(value["children"], key)
      end
    end
  end

  menu_insertion(menus,"")
  

  # This block insert into Database the menus that wasn't present 
  $menu_table.each do |menu|
    parent_menu = Menu.find_by_name(menu[:parent])
    unless Menu.find_by_name(menu[:name])
      if parent_menu.nil?
        Menu.create(:title_link =>menu[:title_link], :description_link => menu[:description_link], :url => menu[:url], :name => menu[:name])
      else
        Menu.create(:title_link =>menu[:title_link], :description_link => menu[:description_link], :url => menu[:url], :name => menu[:name], :parent_id =>parent_menu.id )
      end
    end
  end
end