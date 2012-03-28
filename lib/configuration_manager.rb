class ConfigurationManager
  
  def self.add_method(method)
    class_eval %Q{
    def self.#{method}
      Rails.cache.fetch("CM:#{method}", :expires_on => 1.day) do
        Configuration.find_by_name('#{method}', :order => "created_at DESC").value rescue raise "The 'configurations' table seems to be empty! Please restart the server. If you're running rake tasks, you should launch them separatly. You should prefer 'rake db:schema:load && rake osirails:db:populate' than 'rake db:schema:load osirails:db:populate'"
      end
    end
    def self.#{method}_desc
      Rails.cache.fetch("CM:#{method}_desc", :expires_on => 1.day) do
        Configuration.find_by_name('#{method}', :order => "created_at DESC").description
      end
    end
    def self.#{method}=(value)
      Rails.cache.delete("CM:#{method}")
      option = Configuration.find_by_name('#{method}', :order => "created_at DESC")
      Configuration.create(:name => '#{method}', :value => value, :description => option.description)
    end
    }
  end
  
  def self.reload_methods!
    Configuration.find(:all, :group => "name").each do |option|
      ConfigurationManager.add_method(option.name) unless ConfigurationManager.respond_to?(option.name)
    end
  end
  
  def self.find_configurations_for(feature_name, controller_name)
    ConfigurationManager.methods.sort.grep(/^#{feature_name.downcase}_#{controller_name}.*[^=c]$/) #FIXME Faire en sorte que ça gère _desc
  end
  
  # in development mode, this file is called at every page loaded in the browser
  # so we have to call the reload_methods! method manually, and every time,
  # otherwise the dynamic methods are not present anymore.
  reload_methods! if Rails.env.development?
  
end
