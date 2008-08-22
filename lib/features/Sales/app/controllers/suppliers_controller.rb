class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.find(:all)
  end
  
  def new
    @supplier = Supplier.new
  end
  
  def create
    @supplier = Supplier.new(params[:supplier])
    if @supplier.save
      flash[:notice] = 'Fournisseur ajouté avec succes'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
    
  def show
    @supplier = Supplier.find(params[:id])
  end
  
  def edit
    @supplier = Supplier.find(params[:id])
    @contacts = @supplier.contacts
    @activity_sector = @supplier.activity_sector.name
  end
  
  def update
    @error = false
    @supplier = Supplier.find(params[:id])
    @owner = @supplier
    @activity_sector = @supplier.activity_sector.name
    
    # @error is use to know if all form are valids
    @error = false
    activity_sector_id= nil
    if ActivitySector.find_by_name(params[:new_activity_sector1][:name].capitalize).nil?
      activity_sector = ActivitySector.new(:name => params[:new_activity_sector1][:name])
      if activity_sector.valid?
        activity_sector.save
      end
    end
    activity_sector = ActivitySector.find_by_name(params[:new_activity_sector1][:name])
    if activity_sector != nil
      params[:supplier][:activity_sector_id] = activity_sector.id
      activity_sector_id = activity_sector.id
    else
      @error = true
    end
    @supplier.activity_sector_id= activity_sector_id
    unless @supplier.update_attributes(params[:supplier])
      @error = true
    end
    
    # If contact_form is not null
    unless params[:new_contact_number]["value"].nil?
      #      puts params["contact"]["1"]["first_name"]
      #      puts params["contact"]["1"]["last_name"]
      new_contact_number = params[:new_contact_number]["value"].to_i
      new_contact_number.times do |i|
        # For all new_contact  an instance variable is create.
        # If his parameter is not valid, @error variable is set to true
        eval "unless params['valid_contact_#{i+1}'].nil?
                    unless params['valid_contact_#{i+1}']['value'] == 'false'
                      unless instance_variable_set('@new_contact#{i+1}', Contact.new(params[:new_contact#{i+1}]))
                          @error = true
                      end
                      unless @new_contact#{i+1}.valid?
                          @error = true
                      end
                    end
                  end"
      end
    end
    
    # If all new_contact are valids, they are save 
    unless @error
      new_contact_number.times do |i|
        eval"unless params['valid_contact_#{i+1}'].nil?
                     unless params['valid_contact_#{i+1}']['value'] == 'false'
                       if @new_contact#{i+1} and params['new_contact#{i+1}']['id'] == ''
                         unless @new_contact#{i+1}.save and @owner.contacts << @new_contact#{i+1}
                          @error = true
                         end
                       elsif params['new_contact#{i+1}_id'] != ''                        
                         if @owner.contacts.include?(Contact.find(params['new_contact#{i+1}']['id'])) == false
                            @owner.contacts << Contact.find(params['new_contact#{i+1}']['id'])
                         end
                        else
                          @error = true
                      end
                    end
                  end"
      end
    end
    
    unless @error
      redirect_to(suppliers_path)
    else
      @activity_sector = params[:new_activity_sector1][:name]
      @new_contact_number = params[:new_contact_number]["value"]
      @contacts = @customer.contacts
      render :action => 'edit'
    end    
  end
  
    # DELETE /supplier/1
  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.destroy
    redirect_to(suppliers_path) 
  end
end