class SubcontractorsController < ApplicationController
  helper :thirds, :contacts, :documents, :numbers, :address
  
  before_filter :hack_params_for_contacts_nested_resources, :only => [ :create, :update ]
  
  # GET /subcontractors
  def index
    build_query_for("subcontractor_index")
  end
  
  # GET /subcontractors/:id
  def show
    @subcontractor = Subcontractor.find(params[:id])
  end
  
  # GET /subcontractors/new
  def new
    @subcontractor = Subcontractor.new
  end

  # POST /subcontractors
  def create
    @return_uri = params[:return_uri] # permit to be redirected to order creation (or other uri) when necessary
    
    @subcontractor = Subcontractor.new(params[:subcontractor])
    if @subcontractor.save
      flash[:notice] = "Sous-traitant ajouté avec succès"
      redirect_to subcontractor_path(@subcontractor)
    else
      render :action => 'new'
    end
  end

  # GET /subcontractors/:id/edit
  def edit
    @subcontractor = Subcontractor.find(params[:id])
  end

  # PUT /subcontractors/:id
  def update
    @subcontractor = Subcontractor.find(params[:id])
    if @subcontractor.update_attributes(params[:subcontractor])
      flash[:notice] = "Le sous-traitant a été modifié avec succès"
      redirect_to subcontractor_path(@subcontractor)
    else
      render :action => 'edit'
    end
  end

  # DELETE /subcontractors/:id
  def destroy
    @subcontractor = Subcontractor.find(params[:id])
    @subcontractor.activated = false
    if @subcontractor.save
      redirect_to(subcontractors_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression du sous-traitant"
      redirect_to :back 
    end
  end
  
  private
    ## this method could be deleted when the fields_for method could received params like "customer[establishment_attributes][][address_attributes]"
    ## see the partial view _address.html.erb (thirds/app/views/shared OR thirds/app/views/addresses)
    ## a patch have been created (see http://weblog.rubyonrails.com/2009/1/26/nested-model-forms) but this block of code permit to avoid patch the rails core
    def hack_params_for_contacts_nested_resources
      if params[:contact] and params[:contact][:number_attributes]
        params[:subcontractor][:contact_attributes].each do |contact_attributes|
          number_attributes = params[:contact][:number_attributes].select {|n| contact_attributes[:id] == n[:has_number_id]}
          contact_attributes[:number_attributes] = clean_params(number_attributes, :has_number_id)
        end
      end
      remove_fake_ids(params[:subcontractor][:contact_attributes])
      params.delete(:contact)

    end
end  
