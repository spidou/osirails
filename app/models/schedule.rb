class Schedule < ActiveRecord::Base
  belongs_to :service

  # Search Plugin
  has_search_index :except_attributes => ["created_at", "updated_at", "service_id", "id"],
                   :main_model => false
end
