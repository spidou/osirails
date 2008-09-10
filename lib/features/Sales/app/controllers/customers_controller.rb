class CustomersController < ApplicationController

  helper :documents
  helper :contacts
  
  def index
    @customers = Customer.find(:all)
  end

  def new
    @customer = Customer.new
  end

  def create
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
  end

  def show
    @customer = Customer.find(params[:id])
    @establishments = @customer.establishments
    @contacts = @customer.contacts
  end

  def edit
    @customer = Customer.find(params[:id])
    @establishments = @customer.establishments
    @contacts = @customer.contacts
    @activity_sector = @customer.activity_sector.name unless @customer.activity_sector.nil?
  end

  def update
    # @error is use to know if all form are valids
    @error = false
    @customer = Customer.find(params[:id])
    #    @address = @customer.address
    
    activity_sector_name = params[:customer].delete("activity_sector")
    activity_sector_name[:name].capitalize!

    establishments = params[:customer].delete("establishments")
    
    establishments_test = establishments
    
    establishment_objects = []
    address_objects = []

    contacts = params[:customer].delete("contacts")
    contacts_original = contacts
    contact_objects = []
    
    if (@activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])).nil? and !activity_sector_name[:name].blank?
      @activity_sector = ActivitySector.new(:name => activity_sector_name[:name])
      @customer.activity_sector = @activity_sector
    elsif @activity_sector = ActivitySector.find_by_name(activity_sector_name[:name])
      @customer.activity_sector = @activity_sector
    elsif activity_sector_name[:name].blank?
      @customer.activity_sector = nil
    end    
    
    @customer.activity_sector = @activity_sector
    
    unless @customer.update_attributes(params[:customer])
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
    
    # If establishment_form is not null
    unless (new_establishment_number = params[:new_establishment_number]["value"].to_i) == 0
      new_establishment_number.times do |i|
        unless establishments["#{i+1}"][:valid] == 'false'
          establishments["#{i+1}"][:customer_id] = @customer.id
          address_objects[i] = establishments["#{i+1}"].delete("address")
          establishment_objects[i] =Establishment.new(establishments["#{i+1}"])
          
          ## If city_name and city_zip_code are disabled
          unless address_objects[i][:city].nil?
            establishment_objects[i].address = (address_objects[i] = Address.new(:address1 => address_objects[i][:address1], :address2 => address_objects[i][:address2], 
              :country_name => address_objects[i][:country][:name], :city_name => address_objects[i][:city][:name], :zip_code => address_objects[i][:city][:zip_code]))
          else
            flash[:error] ||= "Le nom de ville et le code postal de l'etablissement #{i+1} ne sont pas définis"
            @error = true
          end
          
          unless establishment_objects[i].valid?
            @error = true
          end
        end
      end
      #      @error = true
    end
    unless @error
      
      contact_objects.each do |contact|
        contact.save
        @customer.contacts << contact
      end
      
      establishment_objects.each do |establishment|
        establishment.save
        @customer.establishments << establishment
      end
      
      address_objects.each do |address|
        address.save
      end
      
      
      flash[:notice] = "Client modifi&eacute; avec succ&egrave;s"
      redirect_to customers_path
    else
      params[:customer][:activity_sector] = {:name => activity_sector_name[:name]} 
      params[:customer][:contacts] = contacts_original

      params[:customer][:establishments] = establishments_test
      params[:new_establishment_number][:value].to_i.times do |i|
       params[:customer][:establishments]["#{i+1}"][:address] = {:country => {:name => address_objects[i].country_name}}
      end
      
      @new_establishment_number = params[:new_establishment_number]["value"]
      @establishments = @customer.establishments
      @new_contact_number = params[:new_contact_number]["value"]
      @contacts = @customer.contacts
#      flash[:error] ||= "Une erreur est survenu lors de la sauvegarde du client"
      render :action => 'edit'
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    if @customer.destroy
      redirect_to(customers_path)
    else
      flash[:error] = "Une erreur est survenu lors de la suppression du contact"
      redirect_to :back 
    end
  end
  
end