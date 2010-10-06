begin
  Menu.all.each do |current_menu|
    # filter menus that need to be checked
    next unless FeatureManager.menus_to_check.include?(current_menu.id)
    menus_to_be_checked = current_menu.self_and_siblings.sort_by(&:position).select {|n| FeatureManager.menus_to_check.include?(n.id)}
    
    # separate menus with and without predefined position to place them into an Array (their index will be their position)
    menus_without_position = menus_to_be_checked.select {|n| n.position == 0}
    menus_with_position    = menus_to_be_checked - menus_without_position
    
    # parse menus to be checked and define their position from their index
    menus_to_be_checked.each do |menu|
      if menus_with_position.include?(menu)
        position = menus_with_position.index(menu) + 1
      else
        position = menus_without_position.index(menu) + menus_with_position.size + 1
      end
      menu.update_attributes(:position => position)
      
      # when the menus's position is correctly configured, delete it from the 'menus_to_check' Array
      FeatureManager.menus_to_check.delete(menu.id)
    end
  end
rescue ActiveRecord::StatementInvalid, Mysql::Error, NameError, Exception => e
  error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  RAKE_TASK ? puts(error) : raise(e)
end
