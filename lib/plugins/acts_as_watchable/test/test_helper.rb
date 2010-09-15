require File.dirname(__FILE__) + '/ruby_env'

class Test::Unit::TestCase
  private
    def create_a_person
      @a_person = Person.new(:first_name => "Jean", 
                             :last_name  => "Dupeux", 
                             :photo      => File.new(File.join(File.dirname(__FILE__), "fixtures", "default_avatar.png")))
      flunk "@conti must be saved to perform the next test" unless @a_person.save
      @a_person
    end
    
    def create_a_district_with_its_representative
      @a_district = District.new(:name => "Dupark", :area => 1000)
      
      @a_district.build_representative(:first_name => "Louis", 
                                       :last_name  => "Labourgue", 
                                       :photo      => File.new(File.join(File.dirname(__FILE__), "fixtures", "default_avatar.png")))
                                                
      flunk "@a_district and its representative must be saved to perform the next test" unless @a_district.save && !@a_district.representative.new_record?
      @a_district
    end
    
    def create_a_district_with_its_schools_and_their_teachers
      @a_district  = District.new(:name => "Dupark", :area => 1000)
      
      @high_school = @a_district.schools.build(:name => "Dupark High School")
      @college     = @a_district.schools.build(:name => "Dupark College")
      
      @conti       = @high_school.teachers.build(:first_name => "Rick", 
                                                 :last_name  => "Conti", 
                                                 :photo      => File.new(File.join(File.dirname(__FILE__), "fixtures", "default_avatar.png")))
      @hoelle      = @college.teachers.build(    :first_name => "Chantal", 
                                                 :last_name  => "Hoelle", 
                                                 :photo      => File.new(File.join(File.dirname(__FILE__), "fixtures", "default_avatar.png")))
           
      flunk "@a_district must be saved to perform the next test" unless @a_district.save
      
      subresources_all_saved = true
      
      [@high_school, @college, @conti, @hoelle].each do |s|
        if s.new_record?
          subresources_all_saved = false 
          break
        end
      end
      
      flunk "All @a_district subresources must be saved to perform the next test" unless subresources_all_saved
    end
    
    def create_a_watchable_function
      function = WatchableFunction.new({:function_type => "District", 
                                        :function_name => "modification_on_area?", 
                                        :function_description => "verify modification on area",
                                        :on_modification => true,
                                        :on_schedule => true })
      function.save!
      flunk "function should be saved" if function.new_record?
      function
    end

    def create_a_scheduled_watchable_function
      function = WatchableFunction.new({:function_type => "District", 
                                        :function_name => "area_is_too_short?", 
                                        :function_description => "verify if area is smaller than 100",
                                        :on_modification => false,
                                        :on_schedule => true })
      function.save!
      flunk "function should be saved" if function.new_record?
      function
    end
    
    
    def put_observation_on(district, person)
      
      watchable = Watchable.new({:has_watchable_type => district.class.name, :has_watchable_id => district.id,:watcher_id => person.id, :all_changes => true})
      watchable.save! 
      flunk "watchable should be saved" if watchable.new_record?
      district
    end
    
    def put_schedule_observation_on(district, person)
      watchable = Watchable.new({:has_watchable_type => district.class.name, :has_watchable_id => district.id, :watcher_id => person.id,:all_changes => true})
      watchable.save! 
      flunk "watchable should be saved" if watchable.new_record?  
      district
    end
    
    def put_relation_on_a_modification_watchable_function_for(district)
      watchable = district.watchables.first
      watchable_function = create_a_watchable_function
      watchable.watchables_watchable_functions.build({:watchable_function_id => watchable_function.id, :on_modification => true})
      watchable.save!
      flunk "watchable function should be saved" if watchable.watchables_watchable_functions.detect(&:new_record?)
      district.reload
    end
    
    def put_relation_on_a_schedule_watchable_function_for(district, watchable_function)
      watchable = district.watchables.first
      watchable.watchables_watchable_functions.build({:watchable_function_id => watchable_function.id, :on_schedule => true, :time_unity => WatchablesWatchableFunction::DAILY_UNITY})
      watchable.save!
      flunk "watchable function should be saved" if watchable.watchables_watchable_functions.detect(&:new_record?)
      district.reload
    end
    
    
    
    
end
