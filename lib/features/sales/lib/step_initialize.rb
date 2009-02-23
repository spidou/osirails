def step_initialize(path)
  begin
    require 'yaml'
    yaml = YAML.load(File.open(path + '/config.yml'))

    name = yaml['name']
    steps  = yaml['steps']
    $step_array = []
    
    # This method insert in $step_table all feature's steps
    def self.step_insertion(step,parent_name)
      unless step.nil?
        step.each_pair do |key,value|
          $step_array << {:name => key, :title => value["title"], :description => value["description"], :parent => parent_name, :position => value["position"]}
          unless value["children"].nil?
            step_insertion(value["children"], key)
          end
        end
      end
    end
    
    step_insertion(steps,"")
    
    # This block insert into Database steps
    unless $step_array.empty?
      $step_array.each do |step_array|
        # Parent step is create if it isn't in database 
        unless parent_step = Step.find_by_name("step_"+step_array[:parent])
          parent_step = Step.create(:name => "step_"+step_array[:parent]) unless step_array[:parent].blank?
        end
      
        # Unless step already exist
        if (step = Step.find_by_name("step_"+step_array[:name])).nil?
          unless (m = Step.create(:title =>step_array[:title], :description => step_array[:description], :name => "step_"+step_array[:name], :parent_id =>(parent_step.id unless parent_step.nil?)))
            puts "The feature #{name} wants to instanciate the step #{m.name}, but it's impossible."
          else
            unless step_array[:position].nil?
              m.insert_at(step_array[:position])
              m.save
            end
          end
        elsif step.title.blank? and !(step_array[:title].nil?)
          step_ = Step.find_by_name(step.name)
          step_.title = step_array[:title]
          step_.description = step_array[:description] unless step_array[:description].nil?
          step_.save
        end
      end
    end
  rescue ActiveRecord::StatementInvalid => e
    puts "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  rescue Mysql::Error => e
    puts "A MySQL error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
  end
end
