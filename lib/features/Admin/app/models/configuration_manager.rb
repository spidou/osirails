class ConfigurationManager
  def ConfigurationManager.add_method(method)
    class_eval %Q{
    def ConfigurationManager.#{method}
      Configuration.find_by_name('#{method}').value
    end
    def ConfigurationManager.#{method}=(value)
      Configuration.create(:name => '#{method}', :value => 'value')
    end
    }
  end
  
  def ConfigurationManager.initialize 
    Configuration.find(:all,:order=>"DESC", :group => "name").each {|option| ConfigurationManager.add_method(option.name)}
  end
end
