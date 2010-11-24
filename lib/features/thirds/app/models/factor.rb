class Factor < ActiveRecord::Base
  has_permissions :as_business_object
  
  has_many :customers
  
  validates_presence_of   :name, :fullname
  validates_uniqueness_of :name
  
  # for pagination : number of instances by index page
  FACTORS_PER_PAGE = 15
  
  journalize :attributes        => [ :name, :fullname ],
             :identifier_method => :name_and_fullname
  
  has_search_index :only_attributes     => [ :id, :name, :fullname ],
                   :only_relationships  => [ :customers ],
                   :identifier          => :name_and_fullname
  
  def name_and_fullname
    "#{name} (#{fullname})"
  end
end
