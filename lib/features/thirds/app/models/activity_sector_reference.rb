class ActivitySectorReference < ActiveRecord::Base
  belongs_to :activity_sector
  belongs_to :custom_activity_sector
  
  validates_presence_of :code
  validates_presence_of :activity_sector_id
  validates_presence_of :activity_sector, :if => :activity_sector_id
  
  validates_uniqueness_of :code

  has_search_index :only_attributes     => [:code],
                   :only_relationships  => [:activity_sector, :custom_activity_sector]

  def get_activity_sector
    custom_activity_sector || activity_sector
  end
  
  def code_and_name
    "#{code} - #{get_activity_sector.name}"
  end
end
