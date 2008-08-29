class CommoditiesInventory < ActiveRecord::Base
  # RelationShip
  belongs_to :commodity
  belongs_to :inventory 
end