class ConfigurationManager
  def ConfigurationManager.add_method(method)
    class_eval %Q{
    def ConfigurationManager.#{method}
      Configuration.find_by_name('#{method}', :order => "created_at DESC").value
    end
    def ConfigurationManager.#{method}_desc
      Configuration.find_by_name('#{method}', :order => "created_at DESC").description
    end
    def ConfigurationManager.#{method}=(value)
      option = Configuration.find_by_name('#{method}', :order => "created_at DESC")
      Configuration.create(:name => '#{method}', :value => value, :description => option.description)
    end
    }
  end
  
  def ConfigurationManager.initialize 
    Configuration.find(:all, :group => "name").each {|option| ConfigurationManager.add_method(option.name)}
  end
  
end
