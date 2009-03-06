def init(config, path)
  begin
    require 'yaml'
    yaml = YAML.load(File.open(path + '/config.yml'))

    # These variables store the feature's configuration from his config.yml file
    name = yaml['name']
    title = yaml['title']
    version = yaml['version']
    dependencies = yaml['dependencies']
    conflicts = yaml['conflicts']
    menus = yaml['menus']
    searches = yaml['search']
    configurations = yaml['configurations']

    # This array store all menus in order than they will be displayed
    $menu_table ||= []

    feature = Feature.find_by_name_and_version(name, version) || Feature.new(:name => name, :version => version, :title => title)
    if ( feature.new_record? and feature.activate_by_default? ) or feature.kernel_feature?
      feature.activated = true
      feature.installed = true
    end
    feature.save

    # Manage the activation of a feature
    return false unless Feature.find_by_name(name).activated

    # Load every file in the app directory
    controller_path = File.join(path, 'app', 'controllers')
    $LOAD_PATH << controller_path
    Dependencies.load_paths << controller_path
    config.controller_paths << controller_path
    model_path = File.join(path, 'app', 'models')
    $LOAD_PATH << model_path
    Dependencies.load_paths << model_path
#    config.controller_paths << model_path
    ActionController::Base.append_view_path(File.join(path, 'app', 'views'))
    $LOAD_PATH << File.join(path, 'app', 'helpers')

    # Load overrides file
    override_path = File.join(directory, 'overrides.rb')
    require override_path if File.exist?(override_path)

    # test and add search indexes into db
    error_message = "syntaxe error in '#{name}' yaml."

    def verify_attribute_type(attr_class, type)
      case attr_class
        when String
          return 1 unless type=="string"
        when Date
          return 1 unless type=="date"
        when DateTime
          return 1 unless type=="date"
        when Time
          return 1 unless type=="date"
        else
          return 1 unless type=="number"
      end
      return 0
    end

    def verify_sub_resources(hash,error_message)
      hash.each_pair do |sub_attribute,value|
        if value.class == {}.class
          value.each_pair do |sub_attribute2,value2|
            if value2.class=={}.class
              return verify_sub_resources(value2,error_message) unless verify_sub_resources(value2,error_message).blank?
            else
              return "#{ error_message } the attribute '#{ sub_attribute2 }' is incorrect for '#{ sub_attribute }'!" unless sub_attribute.constantize.new.respond_to?(sub_attribute2)
            end
          end
        else
          return "#{ error_message } missing attribute type or sub attributes hash for  '#{ sub_attribute }' "
        end
      end
      return ""
    end
     unless searches.blank? or searches == []
      searches.each_key do |key|
        searches[key].each_key do |elmnt|
          searches[key][elmnt].each_pair do |attr_name,attr_type|
            if attr_type.class=={}.class
              raise verify_sub_resources(attr_type,error_message) unless verify_sub_resources(attr_type,error_message).blank?
              raise "#{ error_message } The sub resource '#{ attr_name }' is incorrect for '#{ key }'!" unless key.constantize.new.respond_to?(attr_name)
            else
              raise "#{ error_message } The attribute '#{ attr_name }' is incorrect for '#{ key }'!" unless key.constantize.new.respond_to?(attr_name)

            end
          end
        end
      end
      feature.update_attribute('search', searches)
    end


    #Test of dependencies for this feature
    dependencies_hash = []
    unless dependencies.nil?
      dependencies.each_pair do |key,value|
        dependencies_hash << {:name => key, :version => value}
      end
    end
    feature.update_attribute('dependencies', dependencies_hash)

    #Test of conflicts for this feature
    conflicts_hash = []
    unless conflicts.nil?
      conflicts.each_pair do |key,value|
        conflicts_hash << {:name => key, :version => value}
      end
    end
    feature.update_attribute('conflicts', conflicts_hash)

    #Test if all permission for all menus are present
    def menus_permisisons_verification(menus)
      roles_count = Role.count
      unless menus.nil?
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
    end

    menus_permisisons_verification(menus)


    # This method insert in $menu_table all feature's menus
    def menu_insertion(menus,parent_name)
      unless menus.nil?
        menus.each_pair do |key,value|
          $menu_table << {  :name => key, :title => value["title"], :description => value["description"], :parent => parent_name, :position => value["position"], :skip_display => value["skip_display"]}
          unless value["children"].nil?
            menu_insertion(value["children"], key)
          end
        end
      end
    end

    menu_insertion(menus,"")

    # This block insert into Database the menus that wasn't present
    $menu_table.each do |menu_array|
      # Parent menu is create if it isn't in database
      unless parent_menu = Menu.find_by_name(menu_array[:parent])
        parent_menu = Menu.create(:name => menu_array[:parent])
      end

      # Unless menu already exist
      unless menu_ = Menu.find_by_name(menu_array[:name])
        unless (m = Menu.create(:title =>menu_array[:title], :description => menu_array[:description], :name => menu_array[:name], :parent_id =>parent_menu.id, :feature_id => feature.id, :skip_display => menu_array[:skip_display]))
          puts "The feature #{name} wants to instanciate the menu #{m.name}, but it's impossible. Please change order of feature loading in environment.rb file by changing the 'config.plugins' array"
        else
          unless menu_array[:position].nil?
            m.insert_at(menu_array[:position])
            m.save
          end
        end
      else

        # This block test if a menu isn't define with two different parent in many config file
        $menu_table.each do |menu_test|
          if menu_test[:name] == menu_array[:name]
            if (!menu_test[:position].nil? and !menu_array[:position].nil?) and (menu_test[:position] != menu_array[:position])
              puts "A Position conflict occured with menu '#{menu_array[:name]}'"
            end
            if menu_test[:parent] != menu_array[:parent]
              raise("Double Declaration menu : a parent conflict occured with menu '#{menu_array[:name]}' in file '#{path}/config.yml'")
            end
          end
        end

        # If menu option is not present in database
        if !menu_array[:title].nil? and menu_.title.nil?
          menu_.title = menu_array[:title]
          menu_.insert_at(menu_array[:position]) unless menu_array[:position].nil?
        end
        menu_.description = menu_array[:description] if !menu_array[:description].nil? and menu_.description.nil?

        menu_.save
      end
    end

    # This method insert into Database  all features options that wasn't present
    unless configurations.nil?
      configurations.each_pair do |key,value|
        Configuration.create(:name => name.downcase+"_"+key, :value => value["value"], :description => value["description"]) unless Configuration.find_by_name(name.downcase+"_"+key)
      end
    end
  rescue ActiveRecord::StatementInvalid => e
    puts "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  rescue Mysql::Error => e
    puts "A MySQL error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  end
end
