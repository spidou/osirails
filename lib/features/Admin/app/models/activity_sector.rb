class ActivitySector < ActiveRecord::Base
  belongs_to :customers
  belongs_to :supplier
end
