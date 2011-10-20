## DATABASE STRUCTURE
# A string   "name"
# A string   "title"
# A boolean  "factorisable", :default => false
# A datetime "created_at"
# A datetime "updated_at"

class InvoiceType < ActiveRecord::Base
  validates_presence_of :name
  
  validates_uniqueness_of :name
  
  validates_inclusion_of :factorisable, :in => [true, false]
  
  journalize :identifier_method => :name
  
  has_search_index :only_attributes => [ :id, :name, :title ]
end
