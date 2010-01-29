class GraphicItemSpoolItemsController < ApplicationController
  helper :graphic_items
  
  # GET /orders/[:order_id]/graphic_item_spool_items
  def index
    @spool = GraphicItemSpoolItem.find(:all,:conditions => ["user_id = ?",current_user.id], :order => "created_at DESC")
  end
  
  # GET /orders/[:order_id]/graphic_item_spool_items/empty_spool
  def empty_spool
    GraphicItem.find(:all).each do |gi|
      if gi.is_in_user_spool("image",current_user)
        unless gi.remove_from_graphic_item_spool("image",current_user)
          flash[:error] = "Une erreur est survenue au vidage de la file d'attente"
        end
      end
      if gi.is_in_user_spool("source",current_user)
        unless gi.remove_from_graphic_item_spool("source",current_user)
          flash[:error] = "Une erreur est survenue au vidage de la file d'attente"
        end
      end
    end
    redirect_to :action => :index unless request.xhr?
  end
  
  # GET /orders/[:order_id]/graphic_item_spool_items/[:graphic_item_spool_item_id]/remove_from_spool
  def remove_from_spool
    graphic_item = GraphicItem.find(params[:graphic_item_spool_item_id])
    unless graphic_item.remove_from_graphic_item_spool(params[:file_type],current_user)
      flash[:error] = "Une erreur est survenue au retrait du fichier de la file d'attente"
    end
    redirect_to :action => :index unless request.xhr?
  end
end
