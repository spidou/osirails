class School < ActiveRecord::Base
  belongs_to :district
    
  has_many :teachers, :as => :has_person, :class_name => "Person"
  
  attr_accessor :should_update, :should_destroy
  
  after_save :save_teachers
  
  def should_destroy?
    should_destroy.to_i == 1
  end

  def should_update?
    should_update.to_i == 1
  end
  
  def save_teachers
    teachers.each do |t|
      if t.should_destroy?
        t.destroy
      elsif t.should_update?
        t.save(false)
      end
    end
  end
end
