class Product < ActiveRecord::Base
  # Relationship
  belongs_to :reference, :counter_cache => true
end
