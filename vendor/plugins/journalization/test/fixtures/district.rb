class District < ActiveRecord::Base
  has_many :schools
  has_one  :representative, :as => :has_person, :class_name => "Person"
  
  after_save :save_schools, :save_representative
  
  def to_s
    "#{self.class.name} #{id}: #{name}"
  end
  
  def save_schools
    schools.each do |s|
      if s.should_destroy?
        s.destroy
      elsif s.should_update?
        s.save(false)
      end
    end
  end
  
  def save_representative
    representative.save(false) if representative
  end
end
