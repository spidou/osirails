require_dependency 'app/models/user'

class User
  has_many :graphic_items, :foreign_key => :creator_id
  has_many :graphic_item_spool_items
end
