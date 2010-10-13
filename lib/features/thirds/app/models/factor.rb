class Factor < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :customers
  
  validates_presence_of   :name, :fullname
  validates_uniqueness_of :name
  
  # for pagination : number of instances by index page
  FACTORS_PER_PAGE = 15
  
  has_search_index :only_attributes     => [:name, :fullname],
                   :only_relationships  => [:customers]
  
  def name_and_fullname
    "#{name} (#{fullname})"
  end
end
