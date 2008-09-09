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
    puts "test"
    puts params[:customer].keys
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
    
#    # If establishment_form is not null
#    unless params[:new_establishment_number]["value"] == 0  
#      new_estbalishment_number = params[:new_establishment_number]["value"].to_i
#      new_estbalishment_number.times do |i|
#        # For all new_establishment and addresses,  an instance variable is create.
#        # If his parameter is not valid, @error variable is set to true
#        eval "
#                unless params['valid_establishment_#{i+1}'].nil?
#                
#                  params['new_establishment_address#{i+1}'][:country_name] = params['new_country#{i+1}'][:name]
#                  params['new_establishment_address#{i+1}'][:city_name] = params['new_city#{i+1}'][:name]
#                  params['new_establishment_address#{i+1}'][:zip_code] = params['new_city#{i+1}'][:zip_code]
#
#                  unless params['valid_establishment_#{i+1}']['value'] == 'false'
#                    instance_variable_set('@new_establishment#{i+1}', Establishment.new(params[:new_establishment#{i+1}]))
#                    instance_variable_set('@new_establishment_address#{i+1}', Address.new(params[:new_establishment_address#{i+1}]))
#                    unless @new_establishment#{i+1}.address = @new_establishment_address#{i+1}             
#                      @error = true
#                    end
#                    unless @new_establishment#{i+1}.valid?                  
#                      @error = true
#                    end
#                    unless @new_establishment_address#{i+1}.valid?
#                      @error = true
#                    end
#                  end
#                end"
#      end
#
#      # If all new_establishment and addresses are valids, they are save 
#      unless @error
#        new_estbalishment_number.times do |i|
#          eval"
#                unless params['valid_establishment_#{i+1}'].nil?
#                  unless params['valid_establishment_#{i+1}']['value'] == 'false'
#                    unless @new_establishment_address#{i+1}.save
#                        @error = true
#                    else
#                      unless @customer.establishments << @new_establishment#{i+1}
#                        @error = true
#                       else
#
#                      country = Country.find_by_name(params['new_country#{i+1}'][:name])
#                        unless country.nil?
#                          new_country = Country.create(:name => params['new_country#{i+1}'][:name])
#                          city = City.new(
#                            :name => params['new_city#{i+1}'][:name], 
#                            :zip_code => params['new_city#{i+1}'][:zip_code], 
#                            :country_id => new_country.id)
#                          if country.valid? and city.valid?
#                            country.save
#                            city.save
#                          end
#                        end
#                        unless City.find_by_name_and_country_id(params['new_country#{i+1}'][:name], country.id).nil? and country.nil?
#                          city = City.new(
#                            :name => params['new_city#{i+1}'][:name], 
#                            :zip_code => params['new_city#{i+1}'][:zip_code], 
#                            :country_id => country.id)
#                          if city.valid?
#                            city.save
#                          else 
#                            @error = false
#                          end
#                        end
#
#                      end
#                    end
#                    unless @new_establishment#{i+1}.save
#                      @error = true
#                    end
#                  end
#                end"
#        end
#      end
#    end
    
#    # If contact_form is not null
#    unless params[:new_contact_number]["value"].nil?
#      new_contact_number = params[:new_contact_number]["value"].to_i
#      new_contact_number.times do |i|
#        # For all new_contact  an instance variable is create.
#        # If his parameter is not valid, @error variable is set to true
#        eval "unless params['valid_contact_#{i+1}'].nil?
#                    unless params['valid_contact_#{i+1}']['value'] == 'false'
#                      unless instance_variable_set('@new_contact#{i+1}', Contact.new(params[:new_contact#{i+1}]))
#                        @error = true
#                      end
#                      unless @new_contact#{i+1}.valid?
#                        @error = true
#                      end
#                    end
#                  end"
#      end
#    end
#    
#    # If all new_contact are valids, they are save 
#    unless @error
#      new_contact_number.times do |i|
#        eval"unless params['valid_contact_#{i+1}'].nil?
#                   unless params['valid_contact_#{i+1}']['value'] == 'false'
#                     if @new_contact#{i+1} and params['new_contact#{i+1}']['id'] == ''
#                       unless @customer.contacts << @new_contact#{i+1}
#                       @error = true
#                       end
#                       unless @new_contact#{i+1}.save
#                         @error = true
#                       end
#                     elsif params['new_contact#{i+1}_id'] != ''                        
#                       if @customer.contacts.include?(Contact.find(params['new_contact#{i+1}']['id'])) == false                    
#                         @customer.contacts << Contact.find(params['new_contact#{i+1}']['id'])
#                       end
#                     else
#                       @error = true
#                     end
#                  end
#                end"
#      end
#    end
        
    unless @error
      contact_objects.each do |contact|
        contact.save
        @customer.contacts << contact
      end
      flash[:notice] = "Client modifi&eacute; avec succ&egrave;s"
      redirect_to customers_path
    else
      params[:customer][:activity_sector] = {:name => activity_sector_name[:name]} 
      params[:customer][:contacts] = contacts_original
      @new_establishment_number = params[:new_establishment_number]["value"]
      @establishments = @customer.establishments
      @new_contact_number = params[:new_contact_number]["value"]
      @contacts = @customer.contacts
      flash[:error] = "Une erreur est survenu lors de la sauvegarde du client"
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