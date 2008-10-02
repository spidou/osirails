class Feature < ActiveRecord::Base
  serialize :dependencies
  serialize :conflicts
  serialize :business_objects
  serialize :search
  
  # Constants
  DIR_BASE_FEATURES = "lib/features/"
  DIR_VENDOR_FEATURES = "vendor/features/"
  KERNEL_FEATURES = ["admin"]
  FEATURES_TO_ACTIVATE_BY_DEFAULT = ["admin", "calendars", "cms", "logistics", "memorandum", "products", "rh", "sales", "thirds"]

  validates_presence_of :name
  validates_uniqueness_of :name

  # we use ' #{method_name}_#{content} ex=> able_to_install_conflicts  '  to name ower tabs

  # contains all others features that conflic with current feature  
  attr_reader :able_to_install_conflicts

  # FIXME Maybe we can use the same tab to list  the dependencies of the current feature ? cf.installable activable

  # contains all dependencies of other current feature
  attr_reader :able_to_install_dependencies

  # contains all dependencies of the current feature
  attr_reader :activate_dependencies

  # FIXME Maybe we can use the same tab to list the feature that depend on the current feature? cf.uninstallable & deactivable

  # contains all features that depend on current feature 
  attr_reader :able_to_uninstall_children

  # contains all features that depend on current feature
  attr_reader :deactivate_children

  # contains log concerning installation_script error
  attr_reader :install_log

  # contains log concerning uninstallation_script error
  attr_reader :uninstall_log

  def installed?
    self.installed
  end

  def activated?
    self.activated
  end

  def has_dependencies?
    self.dependencies != nil and self.dependencies.size > 0 ? true : false
  end

  def child_dependencies
    dependencies = []
    Feature.find(:all).each do |feature|
      if feature.has_dependencies?
        feature.dependencies.each do |dependence|
          # raise dependence.version.include?(self.version).to_s if dependence[:name]!="Test3"
          if dependence[:name] == self.name and dependence[:version].to_s.include?(self.version)
            # raise feature.name+" "+feature.version
            dependencies << {:name => feature.name, :version => feature.version}
          end
        end
      end
    end
    dependencies
  end

  def has_child_dependencies?
    child_dependencies.size > 0
  end

  def has_conflicts?
    self.conflicts != nil and self.conflicts.size > 0 ? true : false
  end

  def able_to_install?
    # Test if the current feature has conflicts or dependencies with other feature
    return true if !has_dependencies? and !has_conflicts?

    # Test if the current feature has a conflict with an installed feature
    @able_to_install_conflicts = []
    if has_conflicts?
      conflicts.each do |conflicts|
        if Feature.find(:all, :conditions => ["name=? and version in (?) and installed = 1", conflicts[:name], conflicts[:version]]).size > 0
          feature = Feature.find_by_name(conflicts[:name])
          features_in_conflicts = { :title => feature.title, :version => feature.version }
          @able_to_install_conflicts << features_in_conflicts
        end     
      end
    end

    # Test if the current feature is not present in the conflicts list of all other features
    Feature.find(:all, :conditions => ["installed = 1"]).each do |feature|
      if feature.has_conflicts?
          feature.conflicts.each do |conflicts|
            if conflicts[:name] == self.name and conflicts[:version].include?(self.version)
              @able_to_install_conflicts <<  conflicts
            end
          end
      end
    end

    # Test if the current feature's dependencies are installed
    @able_to_install_dependencies = []
    if has_dependencies?
      dependencies.each do |dependence|
        if Feature.find(:all, :conditions => ["name=? and version in (?) and installed = 1", dependence[:name], dependence[:version]]).size == 0
          @able_to_install_dependencies << dependence
        end     
      end
    end
    @able_to_install_conflicts = @able_to_install_conflicts.uniq
    @able_to_install_dependencies = @able_to_install_dependencies.uniq
    @able_to_install_dependencies.size > 0 || @able_to_install_conflicts.size > 0 ? false : true
  end

  def able_to_uninstall?
    @able_to_uninstall_children = []
    if !self.activated? and self.installed? and !self.child_dependencies.nil?
      self.child_dependencies.each  do |child|
        if Feature.find(:all, :conditions =>["name = ? and version in (?) and (activated = 1 or installed = 1)", child[:name], child[:version]]).size > 0
          feature = Feature.find_by_name_and_version(child[:name], child[:version])
          deactivated_feature = {:title => feature.title, :version => feature.version}
          @able_to_uninstall_children << deactivated_feature
        end
      end
    else
      return false
    end
    @able_to_uninstall_children = @able_to_uninstall_children.uniq
    @able_to_uninstall_children.size > 0 ? false : true
  end

  def able_to_activate?
    @activate_dependencies = []
    return false if !self.installed? or self.activated? 
    unless self.dependencies.nil?
      self.dependencies.each do |dependence|
        if  Feature.find(:all, :conditions => ["name = ? and version in (?) and activated = 0", dependence[:name], dependence[:version]]).size > 0
          @activate_dependencies << dependence
        end
      end
    end
    @activate_dependencies = @activate_dependencies.uniq
    @activate_dependencies.size > 0 ? false : true
  end
  
  def able_to_deactivate?
    @deactivate_children = []
    return false if !self.activated?
    unless self.child_dependencies.nil?
      self.child_dependencies.each do |child|
        if  Feature.find(:all, :conditions => ["name = ? and version in (?) and activated = 1", child[:name], child[:version]]).size > 0
          feature = Feature.find_by_name_and_version(child[:name], child[:version])
          deactivated_feature = {:title => feature.title, :version => feature.version}
          @deactivate_children << deactivated_feature
        end
      end
    end
    @deactivate_children = @deactivate_children.uniq
    @deactivate_children.size > 0 ? false : true
  end

  # Method to verify if the feature belongs to the features that cannot be deactivated 
  def kernel_feature?
    KERNEL_FEATURES.include?(self.name)
  end
  
  def activate_by_default?
    FEATURES_TO_ACTIVATE_BY_DEFAULT.include?(self.name)
  end

  def enable
    if able_to_activate?
      self.activated = true
      if self.save
        # Reload the configuration
        load File.join(RAILS_ROOT, 'config', 'environment.rb')
        return true
      end
    end
    false
  end

  def disable
    if able_to_deactivate?
      self.activated = false
      if self.save
        # Reload the configuration
        load File.join(RAILS_ROOT, 'config', 'environment.rb')
        return true
      end
    end
    false
  end

  def install
    @install_log = []
    return false unless self.able_to_install?
    if File.exist?(File.join(DIR_BASE_FEATURES, self.name, 'install.rb'))
      require File.join(DIR_BASE_FEATURES, self.name, 'install.rb')
    else
      require File.join(DIR_VENDOR_FEATURES, self.name, 'install.rb')
    end
    if feature_install
      self.installed = true
      if self.save
        return true
      end
    else 
      puts @install_log
      return false
    end
  end

  def uninstall
    @uninstall_log = []
    return false unless self.able_to_uninstall?
    if File.exist?(File.join(DIR_BASE_FEATURES, self.name, 'uninstall.rb'))
      require File.join(DIR_BASE_FEATURES, self.name, 'uninstall.rb')
    else
      require File.join(DIR_VENDOR_FEATURES, self.name, 'uninstall.rb')
    end
    if feature_uninstall
      self.installed = false
      if self.save
        return true
      end
    else 
      puts @uninstall_log
      return false
    end
  end

  def check
    # TODO Code the check function: permissions and other
  end

  # Method that return the success message in function of  the  method passed in argument
  def display_flash_notice(method) 
    message = "Le module '#{self.title}' a &eacute;t&eacute; "
    case method
    when "enable"
      message << "activ&eacute;"
    when "disable"
      message << "d&eacute;sactiv&eacute;"
    when "install"
      message << "install&eacute;"
    when "uninstall"
      message << "d&eacute;sinstall&eacute;"
    when "remove"
      message << "supprim&eacute;"
    end
    return message
  end

  # Method that return the failure message in function of  the  method passed in argument 
  # and the differents hashes that contain information about the problem
  def display_flash_error(method)
    message = ""
    case method
    when "enable"
      message = "Une erreur est survenue lors de l'activation du module '#{self.title}'. "
      unless self.activate_dependencies.empty?
        self.activate_dependencies.size > 1 ? message << "Les modules suivants sont requis : " : message << "Le module suivant est requis : "
        deps = []
        self.activate_dependencies.each do |error|
          deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
        end
        message << deps.join(", ")
      end         
    when "disable"
      message = "Une erreur est survenue lors de la désactivation du module '#{self.title}'. "
      unless self.deactivate_children.empty?
        self.deactivate_children.size > 1 ? message << "D'autres modules dépendent de ce module : " : message  << "Un autre module dépend de ce module : "
        deps = []
        self.deactivate_children.each do |error|
          deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
        end
        message << deps.join(", ")
      end
    when "install" 
      message = "Une erreur est survenue lors de l'installaton du module '#{self.title}'. "
      unless self.able_to_install_dependencies.empty?
        self.able_to_install_dependencies.size > 1 ? message << "Les modules suivants sont requis : " : message <<  "Le module suivants est requis : "
        deps = []
        self.able_to_install_dependencies.each do |error|
          deps << "#{error[:name]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
        end
        message << deps.join(", ")
      end
      unless self.able_to_install_conflicts.empty?
        self.able_to_install_conflicts.size > 1 ? message << "<br/>Les conflits suivants ont été détectés : " : message << "<br />Le conflit suivant a été détecté : "
        deps = []
        self.able_to_install_conflicts.each do |error|
          deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
        end
        message << deps.join(", ")
      end
      unless self.install_log.empty?
        self.install_log.each do |error|
          message << "<br />" + error
        end
      end
    when "uninstall"   
      message = "Une erreur est survenue lors de la désinstallation du module '#{self.title}'. "
      unless self.able_to_uninstall_children.empty?
        message << "D'autres modules dépendent de ce module : "
        deps = []
        self.able_to_uninstall_children.each do |error|
          deps << "#{error[:title]} " + (error[:version].class == Array ? "v#{error[:version].join(", v:")}" : "v#{error[:version]}")
        end
        message << deps.join(", ")
      end
      unless self.uninstall_log.empty?
        self.uninstall_log.each do |error|
          message << "<br />" + error
        end
      end  
    when "remove"
      message = "Une erreur est survenue lors de la suppression du module '#{self.title}'. "
    end
    return message
  end

  # Return true if the feature is a base feature stored in lib/features/
  def base_feature?
    dir_base_features = Dir.open("lib/features").sort
    dir_base_features.each do |dir|
      unless dir.start_with?(".") or File.file?(File.join("lib/features", dir))
        begin
          yaml_file = File.open(File.join('lib', 'features', dir, 'config.yml'))
          feature_yaml = YAML.load(yaml_file)
          return true if feature_yaml['name'] == self.name
        rescue Exception => exc
          puts exc
        end
      end
    end
    false
  end

  # Return true if a new feature is able to be added
  def self.able_to_add?
    # TODO Code able_to_add? method
  end

  # Return true if a feature is able to be removed
  def able_to_remove?
    !self.installed and !self.base_feature?
  end

  # Class method to upload a tar.gz to the the server and untar it
  def self.add(options)
    begin
    # Choose the directory and the valid extension
    options[:directory] = "tmp/features/"
    options[:file_type_id] = FileType.find_by_model_owner("Feature").id
    # Up the archive to the server
    FileManager.upload_file(options)
    # Get the name file
    file_name = options[:file]['datafile'].original_filename
    # List the archive
    return "Impossible d'ouvrir l'archive." unless system("cd " + options[:directory] + " && tar -tf " + file_name + " > list_archive.txt")
    # Get the directory name of the new feature
    feature_dir_name = File.open(File.join('tmp', 'features', 'list_archive.txt')).read.split("/").first
    # Untar the archive
    return "Impossible d'ouvrir l'archive" unless system("cd " + options[:directory] + " && tar -xzvf " + file_name )
    # Check if config.yml exist in the new feature
    unless File.exist?( "#{options[:directory]}/#{feature_dir_name}/config.yml")
      FileUtils.rm_rf("#{options[:directory]}/#{feature_dir_name}")
      FileUtils.rm_rf("#{options[:directory]}/#{file_name}")
      return "Le fichier config.yml est absent du nouveau module"
    end
    # Check if init.rb exist in the new feature
    unless File.exist?( "#{options[:directory]}/#{feature_dir_name}/init.rb")
      FileUtils.rm_rf("#{options[:directory]}/#{feature_dir_name}")
      FileUtils.rm_rf("#{options[:directory]}/#{file_name}")
      return "Le fichier init.rb est absent du nouveau module"
    end
    # Open the yaml file config.yml
    yaml = YAML.load(File.open(File.join(options[:directory], feature_dir_name ,'config.yml')))
    # Check if the directory name doesnt already exist in lib/features/
    dir_base_features = Dir.open(DIR_VENDOR_FEATURES).sort
    dir_base_features.each do |dir|
      if dir == yaml['name']
        FileUtils.rm_rf("#{options[:directory]}/#{feature_dir_name}")
        FileUtils.rm_rf("#{options[:directory]}/#{file_name}")
        return "Le r&eacute;p&eacute;toire #{yaml['name']} existe d&eacute;j&agrave;. V&eacute;rifier le fichier config.yml du nouveau module."
      end
    end
    # Rename the feature with his real name and move it to lib/features/
    return "Can't move " + yaml['name'] + " to " + DIR_VENDOR_FEATURES unless system("mv " + File.join(options[:directory], feature_dir_name) + " " + DIR_VENDOR_FEATURES + yaml['name'])
    # Delete the archive list_archive.txt
    File.unlink(File.join(options[:directory], file_name))
    File.unlink(File.join(options[:directory], 'list_archive.txt'))
    # Reload all the environnement configuration (don't modify !)
    # $config is set in environment.rb
    load File.join(RAILS_ROOT, 'config', 'environment.rb')
    rescue Exception => exc
      puts "ERROR: " + exc
      return false
    end
    true
  end

  # Method to remove a feature
  def remove
    return false unless self.able_to_remove?
    system("rm -rf " + File.join('vendor', 'features', self.name)) if self.name.grep(/\//).empty? and self.name.grep(/\.\./).empty?
    self.destroy
  end

end
