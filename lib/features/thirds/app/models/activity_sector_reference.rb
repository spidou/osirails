class ActivitySectorReference < ActiveRecord::Base
  belongs_to :activity_sector
  belongs_to :custom_activity_sector
  
  validates_presence_of :code
  validates_presence_of :activity_sector_id
  validates_presence_of :activity_sector, :if => :activity_sector_id
  
  validates_uniqueness_of :code
  
  validates_format_of :code, :with => /^[0-9]{2}\.[0-9]{2}[A-Z]$/

  has_search_index :only_attributes       => [ :id, :code ],
                   :additional_attributes => { :get_activity_sector_name => :string },
                   :only_relationships    => [ :activity_sector, :custom_activity_sector ],
                   :identifier            => :code_and_short_name
  
  def code=(code)
    super(code.is_a?(String) ? code.upcase : code)
  end
  
  def get_activity_sector
    custom_activity_sector || activity_sector
  end
  
  def get_activity_sector_name
    get_activity_sector && get_activity_sector.name
  end
  
  def code_and_short_name
    "#{code} - #{get_activity_sector.short_name}"
  end
end
