module Osirails
  class BusinessObject < ActiveRecord::Base
    include Permissible 
    def self.can_list?(roles = [])
      Permission.can_list?(Osirails::Document, roles)
    end
  end
end
