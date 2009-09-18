require File.dirname(__FILE__) + '/supplies_manager_controller'

class ConsumablesManagerController < ApplicationController
  helper :supplies_manager
  include SuppliesManagerController
end

