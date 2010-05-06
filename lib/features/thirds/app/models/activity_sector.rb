class ActivitySector < ActiveRecord::Base
  validates_presence_of :name
  
  validates_uniqueness_of :name, :scope => :type
  
  has_search_index :only_attributes => [:name]
  
  def short_name
    name.size > 40 ? name.mb_chars[0...40].to_s.strip + "..." : name unless name.blank?
  end
end
