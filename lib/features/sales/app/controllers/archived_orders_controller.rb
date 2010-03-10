class ArchivedOrdersController < ApplicationController
  helper :orders

  def index
    @orders = []
  end
end
