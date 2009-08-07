class SendedMemorandumsController < ApplicationController
  helper :received_memorandums
  
  # GET /sended_memorandums
  def index
    unless current_user.employee
      flash.now[:error] = "Vous ne pouvez pas envoyer de notes de service si vous n'&ecirc;tes pas associ&eacute;s &agrave; un employ&eacute;"
    end
    memorandum = []
    memorandum += Memorandum.not_published(current_user).sort_by(&:updated_at)
    memorandum += Memorandum.published(current_user).sort_by(&:published_at).reverse
    @sended_memorandums = memorandum.paginate :page => params[:memorandum],:per_page => 10
  end

  # GET /sended_memorandums/show
  def show
    @sended_memorandum = Memorandum.find(params[:id])
  end

  # GET /sended_memorandums/new
  def new
    @sended_memorandum = Memorandum.new
  end

  # POST /sended_memorandums
  def create
    @sended_memorandum = Memorandum.new(params[:memorandum])
    @sended_memorandum.user_id = current_user.id

    if params.has_key?(:published)
      @sended_memorandum.published_at = Time.now
    end

    if params.has_key?(:memorandums_services) and @sended_memorandum.save
      if params[:memorandums_services][:service_id].first != "0"
        memorandums_services_not_recursive = params[:memorandums_services][:service_id]
        if params[:memorandums_services].has_key?(:recursive)
          memorandums_services_recursive = params[:memorandums_services][:recursive]
          memorandums_services_recursive.each do |id|
            MemorandumsService.create(:service_id => id, :memorandum_id => @sended_memorandum.id, :recursive => true)
            memorandums_services_not_recursive.delete_if {|memorandum_not_recursive| memorandum_not_recursive == id}
          end
        end
        memorandums_services_not_recursive.each do |id|
          MemorandumsService.create(:service_id => id, :memorandum_id => @sended_memorandum.id, :recursive => false)          
        end
      else
        service = Service.find_by_service_parent_id(nil)
        MemorandumsService.create(:service_id => service.id, :memorandum_id => @sended_memorandum.id, :recursive => true)
      end
      flash[:notice] = "La note de service est bien cr&eacute;&eacute;e"
      redirect_to :action => 'index'
    else
      @sended_memorandum.errors.add("Destinataire") unless params.has_key?(:memorandums_services)
      render :action => 'new', :locals => {:id => params[:id], :memorandums_services => params[:memorandums_services]}
    end
  end

  # GET /sended_memorandums/1/edit
  def edit
    @sended_memorandum = Memorandum.find(params[:id])
    if @sended_memorandum.published_at?
      flash[:error] = "Vous ne pouvez pas modifier une note de service d&eacute;j&agrave; publi&eacute;"
      redirect_to :action => 'index'
    end
  end

  # PUT /sended_memorandums/1
  def update
    @sended_memorandum = Memorandum.find(params[:id])
    return if @sended_memorandum.published_at?
    if params.has_key?(:published)
      @sended_memorandum.published_at = Time.now
    end
    if params.has_key?(:memorandums_services) and @sended_memorandum.update_attributes(params[:memorandum])
      memorandums_services = @sended_memorandum.memorandums_services    
      if params[:memorandums_services][:service_id].first != "0"
        memorandums_services_not_recursive = params[:memorandums_services][:service_id]
        if params[:memorandums_services].has_key?(:recursive)
          memorandums_services_recursives = params[:memorandums_services][:recursive]
          memorandums_services_recursives.each do |id|
            memorandum_service = MemorandumsService.find_by_service_id_and_memorandum_id(id.to_i, params[:id])
            if memorandum_service.nil?
              MemorandumsService.create(:service_id => id, :memorandum_id => params[:id], :recursive => true)
            else
              unless memorandum_service.recursive
                memorandum_service.recursive = true
                memorandum_service.save
              end
            end
            memorandums_services.delete_if { |memorandums_service| memorandums_service.service_id == id.to_i }
            memorandums_services_not_recursive.delete_if { |mem_ser| mem_ser == id}
          end
        end
        memorandums_services_not_recursive.each do |id|
          memorandum_service = MemorandumsService.find_by_service_id_and_memorandum_id(id.to_i, params[:id])
          if memorandum_service.nil?
            MemorandumsService.create(:service_id => id, :memorandum_id => params[:id], :recursive => false)
          else
            if memorandum_service.recursive
              memorandum_service.recursive = false
              memorandum_service.save
            end
          end
          memorandums_services.delete_if { |memorandums_service| memorandums_service.service_id == id.to_i }              
        end
        memorandums_services.each do |memorandum|
          memorandum.destroy
        end
      else
        memorandums_services.each do |memorandum_service|
          memorandum_service.destroy
        end
        service = Service.find_by_service_parent_id(nil)
        MemorandumsService.create(:service_id => service.id, :memorandum_id => params[:id], :recursive => true)
      end
      flash[:notice] = "La note de service est mise &agrave; jour"
      redirect_to :action => 'index'
    else
      flash[:error] = "Erreur de mise &agrave; jour. V&eacute;rifier que la note de service est associ&eacute;e &agrave; un service."
      render :action => 'edit'
    end
  end

  # uses_tiny_mce permit to configure text_area's options
  uses_tiny_mce "options" =>
  {
    :theme => 'advanced',
    :browsers => %w{msie gecko},
    :theme_advanced_toolbar_location => "top",
    :theme_advanced_toolbar_align => "left",
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => true,
    :paste_auto_cleanup_on_paste => true,
    :theme_advanced_buttons1 => %w{ formatselect fontselect fontsizeselect bold
      italic underline strikethrough separator justifyleft
      justifycenter justifyright indent outdent separator
      bullist numlist forecolor backcolor separator link
      unlink image undo redo},
      :theme_advanced_buttons2 => [],
      :theme_advanced_buttons3 => [],
      :plugins => %w{contextmenu paste}
    }

  end
