require File.dirname(__FILE__) + '/supplies_manager_controller'

class CommoditiesManagerController < ApplicationController
  helper :supplies_manager
  include SuppliesManagerController
end

