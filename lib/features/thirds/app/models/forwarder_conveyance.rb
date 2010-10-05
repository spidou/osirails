class ForwarderConveyance < ActiveRecord::Base
  belongs_to :forwarder
  belongs_to :conveyance
  
  validates_presence_of :conveyance_id
  validates_presence_of :conveyance, :if => :conveyance_id
  
  validates_uniqueness_of :conveyance_id, :scope => :forwarder_id
end
