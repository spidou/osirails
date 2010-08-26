class StepManager
  
  cattr_accessor :all_steps
  @@all_steps ||= []
  
  def initialize(path)
    require 'yaml'
    yaml_path = File.join(path, 'steps.yml')
    yaml = YAML.load(File.open(yaml_path)) || {}
    
    @steps = yaml['steps'] || {}
    @path  = path
    
    load_steps(@steps, "")
    insert_steps_in_database
  end
  
  def load_steps(steps, parent_name)
    steps.each_pair do |step, options|
      options ||= {}
      @@all_steps << { :name => step, :title => options["title"], :description => options["description"], :parent => parent_name, :position => options["position"]}
      load_steps(options["children"], step) unless options["children"].nil?
    end
  end
  
  def insert_steps_in_database
    @@all_steps.each do |step|
      parent_step = Step.find_or_create_by_name("#{step[:parent]}_step") unless step[:parent].blank?
      parent_id = parent_step.nil? ? nil : parent_step.id
      
      if (current_step = Step.find_by_name("#{step[:name]}_step"))
        current_step.title       = step[:title]       if current_step.title.blank?       and !step[:title].nil?       and !step[:title].blank?
        current_step.description = step[:description] if current_step.description.blank? and !step[:description].nil? and !step[:description].blank?
        current_step.save if current_step.changed?
      else
        if (new_step = Step.create(:title => step[:title], :description => step[:description], :name => "#{step[:name]}_step", :parent_id => parent_id))
          unless step[:position].nil?
            new_step.insert_at(step[:position])
            new_step.save
          end
          
          if parent_step
            parent_step_class = parent_step.name.camelize.constantize
            parent_step_class.acts_as_step # explicit call 'acts_as_step' to be sure that the parent is always aware of its children
          end
        else
          puts "An error occured while the creation of the step '#{m.name}'"
        end
      end
    end
  end
  
end
