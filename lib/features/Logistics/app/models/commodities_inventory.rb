class CommoditiesInventory < ActiveRecord::Base
  # RelationShip
  belongs_to :inventory 
end