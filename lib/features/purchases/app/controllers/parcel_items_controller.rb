class ParcelItemsController < ApplicationController
  
  helper :purchase_requests, :purchase_orders, :purchase_order_supplies, :parcels
  
  def cancel_form
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    unless @parcel_item.can_be_cancelled?
      error_access_page(412)
    end
  end
  
  def cancel
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    if @parcel_item.can_be_cancelled?
      @parcel_item.attributes = params[:parcel_item]
      @parcel_item.cancelled_by = current_user.id
      if @parcel_item.cancel
        flash[:notice] = "Le contenu correspondant a été annulé."
        redirect_to( purchase_order_parcel_path(@parcel_item.purchase_order_supply.purchase_order, @parcel_item.parcel))
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  def report_form
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    unless @parcel_item.can_be_reported?
      error_access_page(412)
    end
  end
  
  def report
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    if @parcel_item.can_be_reported?
      @parcel_item.attributes = params[:parcel_item]
      if @parcel_item.report
        flash[:notice] = "Le contenu correspondant a été signalé comme défectueux."
        redirect_to  @parcel_item.parcel
      else
        render :action => "report_form"   
      end
    else
      error_access_page(412)
    end
  end
  
end
