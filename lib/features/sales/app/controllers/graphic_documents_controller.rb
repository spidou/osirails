class GraphicDocumentsController < ApplicationController
  acts_as_step_controller :sham => true
  helper :graphic_items  
  
  # GET /orders/:order_id/graphic_documents
  def index
    @employee = current_user.employee
    @enabled_graphic_documents = @order.graphic_documents.find(:all, :conditions => ["cancelled is NULL or cancelled=false"])
  end  
  
  # GET /orders/:order_id/graphic_documents/:id
  def show
    @employee = current_user.employee
    @graphic_document = GraphicDocument.find(params[:id])
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @graphic_document.id})
  end
  
  # GET /orders/:order_id/graphic_documents/new
  def new
    @graphic_document = @order.graphic_documents.build
    @graphic_item_types = GraphicDocumentType.find(:all)
    @graphic_unit_measures = GraphicUnitMeasure.find(:all)
  end
  
  # POST /orders/:order_id/graphic_documents
  def create
    @graphic_document = @order.graphic_documents.build(params[:graphic_document])
    @graphic_document.creator = current_user.employee
    
    @graphic_item_types = GraphicDocumentType.find(:all)
    @graphic_unit_measures = GraphicUnitMeasure.find(:all)  

    if @graphic_document.save
      flash[:notice] = "Le document graphique a été créé avec succès."
      redirect_to order_graphic_documents_path
    else
      render :action => "new"
    end
  end
  
  # GET /orders/:order_id/graphic_documents/:id/edit
  def edit
    @graphic_document = GraphicDocument.find(params[:id])
    @graphic_item_types = GraphicDocumentType.find(:all)
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @graphic_document.id})
  end
  
  # PUT /orders/:order_id/graphic_documents/:id/update
  def update
    @graphic_document = GraphicDocument.find(params[:id])
    @graphic_item_types = GraphicDocumentType.find(:all)
    @graphic_item_versions = GraphicItemVersion.find(:all, :conditions => {:graphic_item_id => @graphic_document.id})

    if @graphic_document.update_attributes params[:graphic_document]
      flash[:notice] = "Le document graphique a été modifié avec succès."
      redirect_to order_graphic_document_path
    else
      render :action => "edit"
    end
  end
  
  # GET /orders/:order_id/graphic_documents/:id/cancel
  def cancel
    @graphic_document = GraphicDocument.find(params[:graphic_document_id])    
    if @graphic_document.can_be_cancelled?
      unless @graphic_document.cancel
        flash[:error] = "Une erreur est survenue à la désactivation du document graphique"
      end
      redirect_to order_graphic_documents_path
    else
      error_access_page(403)
    end
  end
  
  # DELETE /orders/:order_id/graphic_documents/:id
  def destroy
    @graphic_document = GraphicDocument.find(params[:id])
    unless @graphic_document.destroy
      flash[:error] = "Une erreur est survenue à la suppression du document graphique"
    end
    redirect_to order_graphic_documents_path
  end
end
