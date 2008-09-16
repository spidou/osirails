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
      
      # @error is use to know if all form are valids
      @error = false
      @customer = Customer.find(params[:id])
      
      ## dup is use to create a copy of params[:customer] because if we use simply =, when delete method is use on customer variable, params is modify too
      customer = params[:customer].dup
      
      activity_sector_name = params[:customer][:activity_sector].dup      
      activity_sector_name[:name].capitalize!
    
      #FIXME See if this block can be in activity_sector models
      if (@activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])).nil? and !activity_sector_name[:name].blank?
        @activity_sector = ActivitySector.new(:name => activity_sector_name[:name])
        @customer.activity_sector = @activity_sector
      elsif @activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])
        @customer.activity_sector = @activity_sector
      elsif activity_sector_name[:name].blank?
        @customer.activity_sector = nil
      end    
    
      @customer.activity_sector = @activity_sector

      customer.delete("activity_sector")
      customer.delete("contacts")
      customer.delete("establishments")
      customer.delete("documents")
      
      ## Save customer attributes
      unless @customer.update_attributes(customer)
        @error = true
      else
        @activity_sector.save
      end
      
      ## If contact_form is not null
      if Contact.can_add?(current_user)        
        ## This variable is use to recreate in params the contacts that are enable
        contact_params_index = 0 
        if params[:new_contact_number]["value"].to_i > 0
          @contact_objects = []
          contacts = params[:customer][:contacts].dup
          params[:new_contact_number]["value"].to_i.times do |i|
            unless contacts["#{i+1}"][:valid] == 'false'
              numbers = contacts["#{i+1}"].delete("numbers")
              @contact_objects << Contact.new(contacts["#{i+1}"])              
              numbers.each_value do |number|
                number['visible'] = false if number['visible'].nil?
                @contact_objects.last.numbers << Number.new(number) unless number.blank?
              end
              params[:customer][:contacts]["#{contact_params_index += 1}"] = params[:customer][:contacts]["#{i + 1}"]
            end
          end
          params[:new_contact_number]["value"]  = @contact_objects.size
          ## Test if all contacts enable are valid
          @contact_objects.size.times do |i|
            @error = true unless @contact_objects[i].valid?
          end
        end
      end
      
      ## If establishment_form is not null
      if Establishment.can_add?(current_user)
        establishment_params_index = 0 
        if params[:new_establishment_number]["value"].to_i > 0
          @establishment_objects = []
          @address_objects = []
          establishments = params[:customer][:establishments].dup
          
          params[:new_establishment_number]["value"].to_i.times do |i|
            unless establishments["#{i+1}"][:valid] == "false"
              @establishment_objects << Establishment.new(establishments["#{i+1}"])
              params[:customer][:establishments]["#{establishment_params_index += 1}"] = params[:customer][:establishments]["#{i + 1}"]
            end
          end
          params[:new_establishment_number]["value"]  = @establishment_objects.size
          ## Test if all establishments enable are valid
          @establishment_objects.size.times do |i|
            @error = true unless @establishment_objects[i].valid?
          end
        end
      end
     
      if Document.can_add?(current_user)
        if params[:new_document_number]["value"].to_i > 0
          documents = params[:customer][:documents].dup
          @document_objects = Document.create_all(documents, @customer)
        end
        document_params_index = 0
        params[:new_document_number]["value"].to_i.times do |i|
          params[:customer][:documents]["#{document_params_index += 1}"] = params[:customer][:documents]["#{i + 1}"] unless params[:customer][:documents]["#{i + 1}"][:valid] == "false"
        end
        ## Test if all documents enable are valid
        unless @document_objects.nil?
          @document_objects.size.times do |i|
            @error = true unless @document_objects[i].valid?
          end
          ## Reaffect document number
          params[:new_document_number]["value"]  = @document_objects.size
        end
      end     
      
      unless @error
        flash[:notice] = "Client modifi&eacute; avec succ&egrave;s"
        if params[:new_document_number]["value"].to_i > 0
          @document_objects.each do |document|
            document.save
            @customer.documents << document
            document.create_thumbnails
          end
        end
        
        if params[:new_contact_number]["value"].to_i > 0
          @contact_objects.each do |contact|
            contact.save
            @customer.contacts << contact unless @customer.contacts.include?(contact)
          end
        end
        
        if params[:new_establishment_number]["value"].to_i > 0
          @establishment_objects.each do |establishment|
            establishment.save
            @customer.establishments << establishment
          end
        end
        
        redirect_to customers_path
      else
        flash[:error] ||= "Une erreur est survenue lors de la sauvergarde du client"
        @new_establishment_number = params[:new_establishment_number]["value"]
        @establishments = @customer.establishments
        @new_contact_number = params[:new_contact_number]["value"]
        @new_document_number = params[:new_contact_number]["value"]
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