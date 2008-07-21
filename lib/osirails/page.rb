module Osirails
  class Page < ActiveRecord::Base
    belongs_to :parent_page, :class_name => 'Page', :foreign_key => 'parent_id'
    include Permissible
    
    
    
  end
end