class SuppliersController < ApplicationController
  
  helper :thirds
  helper :contacts  
  
  # GET /suppliers
  # GET /suppliers.xml
  def index
    if Supplier.can_list?(current_user)
      @suppliers = Supplier.find(:all)
    else
      error_access_page(403)
    end
  end
  
  # GET /suppliers/1
  # GET /suppliers/1.xml
  def show
    ## Objects use to test permission
    @contact_controller = Menu.find_by_name('contacts')
      
    if Supplier.can_view?(current_user)
      @supplier = Supplier.find(params[:id])
      @contacts = @supplier.contacts
    else
      error_access_page(403)
    end
  end
  
  # GET /suppliers/new
  def new
    if Supplier.can_add?(current_user)
      @supplier = Supplier.new
    else
      error_access_page(403)
    end
  end
  
  # POST /suppliers
  def create
    if Supplier.can_add?(current_user) 
      activity_sector = params[:supplier].delete("activity_sector")
      activity_sector[:name].capitalize!
    
      iban = params[:supplier].delete("iban")
      @iban = Iban.new(iban)
    
      @supplier = Supplier.new(params[:supplier])
    
      if (@activity_sector = ActivitySector.find_by_name(activity_sector[:name])).nil? and !activity_sector[:name].blank?
        @activity_sector = ActivitySector.create(:name => activity_sector[:name])
        @supplier.activity_sector = @activity_sector
      elsif @activity_sector = ActivitySector.find_by_name(activity_sector[:name])
        @supplier.activity_sector = @activity_sector  
      end

      @supplier.activity_sector = @activity_sector
      @supplier.iban = @iban
    
      if @supplier.save
        @activity_sector.save
        @iban.save
        flash[:notice] = 'Fournisseur ajouté avec succes'
        redirect_to :action => 'index'
      else
        flash[:error] = 'Une erreur est survenu lors de la création du fournisseur'
        params[:supplier][:activity_sector] = {:name => activity_sector[:name]}
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /suppliers/1/edit
  def edit
    ## Objects use to test permission
    @contact_controller = Menu.find_by_name('contacts')
    @establishment_controller =Menu.find_by_name('establishments')
    
    if Supplier.can_edit?(current_user)
      @supplier = Supplier.find(params[:id])
      @contacts = @supplier.contacts
      @activity_sector = @supplier.activity_sector.name
    else
      error_access_page(403)
    end
  end
  
  # PUT /suppliers/1
  def update
    if Supplier.can_edit?(current_user)
      # @error is use to know if all form are valids
      @error = false
      @supplier = Supplier.find(params[:id])

      activity_sector_name = params[:supplier].delete("activity_sector")
      activity_sector_name[:name].capitalize!
    
      iban = params[:supplier].delete("iban")
    
      contacts = params[:supplier].delete("contacts")
      contacts_original = contacts
      contact_objects = []    
    
      if (@activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])).nil? and !activity_sector_name[:name].blank?
        @activity_sector = ActivitySector.new(:name => activity_sector_name[:name])
        @supplier.activity_sector = @activity_sector
      elsif @activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])
        @supplier.activity_sector = @activity_sector
      elsif activity_sector_name[:name].blank?
        @supplier.activity_sector = nil
      end    
 
      @supplier.activity_sector = @activity_sector
      @supplier.iban.update_attributes(iban)

      unless @supplier.update_attributes(params[:supplier])
        @error = true
      else
        @activity_sector.save
      end

      # If contact_form is not null
      unless (new_contact_number = params[:new_contact_number]["value"].to_i) == 0
        new_contact_number.times do |i|
          unless contacts["#{i+1}"][:valid] == 'false'
            if contacts["#{i+1}"][:id].blank?
              contacts["#{i+1}"].delete("id")
              contacts["#{i+1}"].delete("selected")
              contacts["#{i+1}"].delete("valid")
              contact_objects[i] = Contact.new(contacts["#{i+1}"])
              unless contact_objects[i].valid?
                @error = true
              end
            else
              contact_objects[i] = Contact.find(contacts["#{i+1}"][:id])
            end                  
          end
        end
      end
    
      unless @error
        contact_objects.each do |contact|
          contact.save
          @supplier.contacts << contact
        end      
        flash[:notice] = 'Fournisseur ajouté avec succes'     
        redirect_to(suppliers_path)
      else
        params[:supplier][:activity_sector] = {:name => activity_sector_name[:name]}
        params[:supplier][:contacts] = contacts_original
        flash[:error] = 'Une erreur est survenu lors de sauvegarde du fournisseur'
        @new_contact_number = params[:new_contact_number]["value"]
        @contacts = @supplier.contacts
        render :action => 'edit'
      end
    else
      error_access_page(403)
    end
  end
  
  # DELETE /supplier/1
  def destroy
    if Supplier.can_delete?(current_user)
      @supplier = Supplier.find(params[:id])
      @supplier.destroy
      redirect_to(suppliers_path) 
    else
      error_access_page(403)
    end
  end
end