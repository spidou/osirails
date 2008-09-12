class CustomersController < ApplicationController

  helper :documents
  helper :contacts
  
  # GET /customers
  # GET /customers.xml
  def index
    if Customer.can_list?(current_user)
      @customers = Customer.find(:all)
    else
      error_access_page(403)
    end
  end
  
  # GET /customers/1
  # GET /customers/1.xml
  def show
    if Customer.can_view?(current_user)
      ## Objects use to test permission
      @contact_controller = Menu.find_by_name('contacts')
      @establishment_controller =Menu.find_by_name('establishments')
      
      @customer = Customer.find(params[:id])
      @establishments = @customer.establishments
      @contacts = @customer.contacts
    else
      error_access_page(403)
    end
  end
  
  # GET /customers/new
  # GET /customers/new.xml
  def new
    if Customer.can_add?(current_user)
      @customer = Customer.new
    else
      error_access_page(403)
    end
  end

  # POST /customers
  # POST /customers.xml
  def create
    if Customer.can_add?(current_user) 
      activity_sector_name = params[:customer].delete("activity_sector")
      activity_sector_name[:name].capitalize!
    
      @customer = Customer.new(params[:customer])
    
      if (@activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])).nil? and !activity_sector_name[:name].blank?
        @activity_sector = ActivitySector.new(:name => activity_sector_name[:name])
        @customer.activity_sector = @activity_sector
      elsif @activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])
        @customer.activity_sector = @activity_sector  
      end
    
      if @customer.save
        ## In case of activity_sector wasn't present in database
        @activity_sector.save
        flash[:notice] = "Client ajout&eacute; avec succes"
        redirect_to :action => 'index'
      else
        flash[:error] = 'Une erreur est survenu lors de la création du fournisseur'
        params[:customer][:activity_sector] = {:name => activity_sector_name[:name]}
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end

  # GET /customers/1/edit
  def edit
    ## Objects use to test permission
    @contact_controller = Menu.find_by_name('contacts')
    @establishment_controller =Menu.find_by_name('establishments')
    @document_controller =Menu.find_by_name('documents')
      
    if Customer.can_edit?(current_user)
      @customer = Customer.find(params[:id])
      @establishments = @customer.establishments
      @contacts = @customer.contacts
      @documents =@customer.documents
      @activity_sector = @customer.activity_sector.name unless @customer.activity_sector.nil?
    else
      error_access_page(403)
    end
  end

  # PUT /customerss/1
  # PUT /customerss/1.xml
  def update
    if Customer.can_edit?(current_user)
      ## Objects use to test permission
      @contact_controller = Menu.find_by_name('contacts')
      @establishment_controller =Menu.find_by_name('establishments')
      @document_controller =Menu.find_by_name('documents')
      
      customer = params[:customer]
      
      # @error is use to know if all form are valids
      @error = false
      @customer = Customer.find(params[:id])
#      raise params[:customer][:activity_sector].to_s    
      activity_sector_name = customer.delete("activity_sector")
#      raise params[:customer][:activity_sector].to_s
      
      activity_sector_name[:name].capitalize!
      
      establishments = customer.delete("establishments")
      
      @establishment_objects = []
      @address_objects = []
      
      contacts = customer.delete("contacts")
      
      @contact_objects = []
    
      if (@activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])).nil? and !activity_sector_name[:name].blank?
        @activity_sector = ActivitySector.new(:name => activity_sector_name[:name])
        @customer.activity_sector = @activity_sector
      elsif @activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])
        @customer.activity_sector = @activity_sector
      elsif activity_sector_name[:name].blank?
        @customer.activity_sector = nil
      end    
    
      @customer.activity_sector = @activity_sector
    
      unless @customer.update_attributes(customer)
        @error = true
        flash[:error] ||= "Une erreur est survenue lors de la sauvergarde du client"
      else 
        @activity_sector.save
      end
    
      if Contact.can_add?(current_user)
        # If contact_form is not null
        params_index = 0
        contact_object_index = -1
        
        if (params[:new_contact_number]["value"].to_i) > 0
          params[:new_contact_number]["value"].to_i.times do |i|       
            unless contacts["#{i+1}"][:valid] == 'false'
              @contact_objects[contact_object_index += 1] = Contact.new(contacts["#{i+1}"])
            end
          end
          params[:new_contact_number]["value"] = @contact_objects.size
          @contact_objects.size.times do |i|   
            @error = true unless @contact_objects[i].valid?
          end
        end
      end
      
      
      if Establishment.can_add?(current_user)
        # If establishment_form is not null
        params[:customer][:establishments] = {}
        
        if (params[:new_establishment_number]["value"].to_i) > 0
          establishments.size.times do |i|

            unless establishments["#{i+1}"][:valid][:value] == "false"
              @establishment_objects << Establishment.new(establishments["#{i+1}"])
              params[:customer][:establishments]["#{params[:customer][:establishments].keys.size + 1}"] = {}
              params[:customer][:establishments]["#{params[:customer][:establishments].keys.size + 1}"] = establishments["#{i+1}"]
            end
          end
          @establishment_objects.size.times do |i| 
          @error = true unless @establishment_objects[i].valid?
          end
        end
      end
      
      
      #      if Document.can_add?(current_user)
      #        unless params[:upload][:datafile].blank?
      #          params[:document][:upload] = params[:upload]
      #          params[:document][:owner] = @customer
      #          @document = Document.new(params[:document])
      #        end
      #      end
      
      
      unless @error
        
        #        unless params[:upload][:datafile].blank?
        #          if Document.can_add?(current_user)
        #            @customer.documents << @document
        #          end
        #        end
      
        @contact_objects.each do |contact|
          contact.save
          @customer.contacts << contact unless @customer.contacts.include?(contact)
        end
      
        @establishment_objects.each do |establishment|
          establishment.save
          @customer.establishments << establishment
        end
        
        @address_objects.each do |address|
          address.save
        end      
        flash[:notice] = "Client modifi&eacute; avec succ&egrave;s"
        redirect_to customers_path
      else
#        params[:customer][:activity_sector] = {:name => activity_sector_name[:name]} 
        
      
        @new_establishment_number = params[:new_establishment_number]["value"]
        @establishments = @customer.establishments
        @new_contact_number = params[:new_contact_number]["value"]
        @contacts = @customer.contacts
        @documents =@customer.documents
        render :action => 'edit'
      end
    else
      error_access_page(403)
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    if Customer.can_delete?(current_user)
      @customer = Customer.find(params[:id])
      if @customer.destroy
        redirect_to(customers_path)
      else
        flash[:error] = "Une erreur est survenu lors de la suppression du contact"
        redirect_to :back 
      end
    else
      error_access_page(403)
    end
  end
  
end