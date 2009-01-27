class EstablishmentsController < ApplicationController
  
  helper :contacts
  #  protect_from_forgery :except => [:auto_complete_for_city_name]
  
  # GET /establishments
  # GET /customer/1/establishments
  def index
    if params[:customer_id]
      @establishments = Customer.find(params[:customer_id]).activated_establishments
    else
      error_access_page(400)
    end
  end
  
  def show
    if Establishment.can_view?(current_user)
      @contact_controller = Menu.find_by_name("contacts")    
      @establishment = Establishment.find(params[:id])
      @contacts = @establishment.contacts
      @customer = Customer.find(params[:customer_id])
    end
  end
  
  def edit
    if Establishment.can_edit?(current_user)
      @establishment = Establishment.find(params[:id])
      @customer = Customer.find(params[:customer_id])
      @contacts = @establishment.contacts
      @contact_controller = Menu.find_by_name('contacts')
    end
  end
  
  def update
    if Establishment.can_edit?(current_user)
      @establishment = Establishment.find(params[:id])
      @contact_controller = Menu.find_by_name('contacts')
      @error = false
    
      @establishment = Establishment.find(params[:id])
      @address = @establishment.address
      @customer = Customer.find(params[:customer_id])
      @contacts = @establishment.contacts
    
      establishment = params[:establishment].dup
      contacts = establishment.delete("contacts")
      address = establishment.delete("address")
    
    
      country = Country.find_by_name(address[:country_name])
      if country.nil?
        country = Country.new(:name => address[:country_name])
      end
      if country.valid?
        country.save
      end
      if address[:city].nil?
        @error = true
      else
        if City.find_by_name_and_country_id(address[:city][:name], country.id).nil?
          city = City.new(
            :name => address[:city][:name], 
            :zip_code => address[:city][:name][:zip_code], 
            :country_id => country.id)
          if city.valid?
            city.save
          end
          address[:city_name] = address[:city][:name]
          address[:zip_code] = address[:city][:zip_code]
        end
      end
    
      address[:country_name] = address[:country][:name]
    
    
      address.delete("country")
      address.delete("city")
    
      unless @establishment.update_attributes(establishment)
        @error = true
      end
      unless @address.update_attributes(address)
        @error = true
      end

      ## If contact_form is not null
      if Contact.can_add?(current_user)        
        ## This variable is use to recreate in parms the contacts that are enable
        contact_params_index = 0 
        if params[:new_contact_number]["value"].to_i > 0
          @contact_objects = []
          contacts = params[:establishment][:contacts].dup
          params[:new_contact_number]["value"].to_i.times do |i|
            unless contacts["#{i+1}"][:valid] == 'false'
              @contact_objects << Contact.new(contacts["#{i+1}"])
              params[:establishment][:contacts]["#{contact_params_index += 1}"] = params[:establishment][:contacts]["#{i + 1}"]
            end
          end
          params[:new_contact_number]["value"]  = @contact_objects.size
          ## Test if all contacts enable are valid
          @contact_objects.size.times do |i|
            @error = true unless @contact_objects[i].valid?
          end
        end
      end
    
      if @error 
        flash[:error] = "Une erreur est survenue lors de la sauvegarde de l'&eacute;tablissement"
        @new_contact_number = params[:new_contact_number]["value"]
        render :action => "edit"
      else
      
        if params[:new_contact_number]["value"].to_i > 0
          @contact_objects.each do |contact|
            contact.save
            @establishment.contacts << contact unless @establishment.contacts.include?(contact)
          end
        end
        
        flash[:notice] = "&Eacute;tablissement sauvegard&eacute;e avec succes"
        redirect_to :action => "show"
      end
    end
  end

  def destroy
    if Establishment.can_delete?(current_user)
      @establishment = Establishment.find(params[:id])
      @customer = @establishment.customer
      @establishment.activated = false
      @establishment.save
      redirect_to(edit_customer_path(@customer))
    end
  end
  
end