module Rails
  def root
    File.dirname(__FILE__)
  end
end

include Rails

RAILS_ROOT = Rails.root

$LOAD_PATH << File.dirname(__FILE__)

require 'test/unit'
require 'boot' unless defined?(ActiveRecord)

require 'active_record'

require File.join(File.dirname(__FILE__), 'lib', 'activerecord_test_case')

path = File.join(File.dirname(__FILE__), '..', 'app', 'models')  
dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.load_paths << path 
dep.load_once_paths.delete(path)

require 'rubygems'

gem 'thoughtbot-shoulda'
require 'shoulda'

gem 'paperclip'
require 'paperclip'
include Paperclip

# define logger for journalization
log_file = File.join(File.dirname(__FILE__), "test.log")
ActiveRecord::Base.logger = Logger.new(log_file)

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
end
