class CommoditiesInventory < ActiveRecord::Base
  belongs_to :inventory
  belongs_to :commodity
end
