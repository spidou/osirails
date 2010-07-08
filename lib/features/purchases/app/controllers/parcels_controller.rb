class ParcelsController < ApplicationController
  def alter_status
    @parcel = Parcel.find(params[:parcel_id])
    if params[:status]
      redirect_to purchase_order_processing_parcel_path(params[:parcel_id])
    else
      redirect_to purchase_order_path(@parcel.parcel_items.first.purchase_order_supply.purchase_order)
    end
  end
end
