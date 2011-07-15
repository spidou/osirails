#Ce contrôlleur renferme la logique associée aux pointages d'un employé.
#Pour plus de détails, consulter la documentation de chaque méthode d'instance publique.
class CheckingsController < ApplicationController

  #Cet appel de helper me permet de pouvoir utiliser les helpers correspondants et se situants dans la partie employé et number
  helper :employees,:numbers

  # GET /checkings
  #Cette méthode récupère tout les employés que l'utilisateur peut pointer.
  #*  Si la variable locale +@as_employee_id+,
  # la variable +@subordinates+ est initialisé par les employés que l'utilisateur va pointer en tant que l'employé choisis.
  #*  Sinon la variable +@subordinates+ est initialisé par les employées à pointer de l'utisateur actuel.
  def index
    @date = (params[:date] ||Date.today).to_date
    if @as_employee_id = params[:as_employee_id] 
      @as_employee = Employee.find(@as_employee_id)
      @subordinates =  @as_employee.subordinates
    else
      @subordinates = current_user.employee.subordinates
#      @subordinates = Employee.all
    end
  end

  
  # GET /checkings/new
  #Cette méthode crée un nouvel objet Checking reposant sur le contenu de @date.
  #*  Si l'employé à pointer n'existe pas alors l'action de rediction est vers l'index '
  #*  Sinon la création d'un pointage pour cet employé à la date du pointage choisis  initialise la variable +@checking+
  def new
    @date = (params[:date] || Date.today).to_date
    @employee = Employee.find(params[:employee_id])    
    @as_employee_id = params[:as_employee_id].blank? ? nil : params[:as_employee_id] 
    if @as_employee_id
      @as_employee = Employee.find(@as_employee_id)
    end
    if @employee.nil?
      render :action => "index"      
    end
    if @checking = @employee.checkings.first(:conditions => ['date = ? ' , @date]) 
      redirect_to :action => "edit", :id => @checking.id , :employee_id => @employee.id, :date => @date ,  :as_employee_id => @as_employee_id 
    else
      @checking = @employee.checkings.build(:date => @date)
    end
  end

  # GET /checkings/edit
  #Cette méthode récupère un objet Checking déjàs créer reposant sur le contenu de @date et de @employee.
  #*  Si l'employé à pointer n'existe pas alors l'action de rediction est vers l'index '
  #*  Sinon la modification d'un pointage pour cet employé à la date du pointage choisis peut initialiser la variable +@checking+
  def edit
    @date = (params[:date] || Date.today).to_date
    @employee = Employee.find(params[:employee_id])    
    if params[:as_employee_id] 
      @as_employee_id = params[:as_employee_id]
      @as_employee = Employee.find(@as_employee_id)
    end
    if @employee.nil?
      render :action => "index"
    else
      @checking = Checking.find(params[:id])
    end
  end 

  #Cette méthode crée un nouvel objet Checking reposant sur le contenu de params[:checking].
  #*  Si l'appel de méthode +save+ sur cet objet réussit, une &lfg;flash notice&rfg; prend effet et l'action +index+ est appelée.
  #*  Si +save+ échoue, c'est l'action +new+ qui est appelée à la place.
  def create
    @checking = Checking.new(:employee_id => params[:checking].delete(:employee_id) , :date => params[:checking].delete(:date))
    @checking.attributes =  params[:checking]
    @as_employee_id = params[:as_employee_id].blank? ? nil : params[:as_employee_id] 
    @date = @checking.date
    if @checking.save
      flash[:notice] = "Le pointage a été créé avec succès."
      redirect_to :action => "index" , :employee_id => @checking.employee_id, :date => @date ,  :as_employee_id => @as_employee_id
    else
      @checking.attributes =  params[:checking]
      @employee = Employee.find(@checking.employee_id )    
      render :action => "new", :date => @date
    end
  end

  #Cette méthode modifier un objet Checking existant reposant sur le contenu de params[:checking].
  #*  Si l'appel de méthode +update+ sur cet objet réussit, une &lfg;flash notice&rfg; prend effet et l'action +index+ est appelée.
  #*  Si +update+ échoue, c'est l'action +edit+ qui est appelée à la place.
   def update
    @checking = Checking.find(params[:id])    
    @date = @checking.date
    @as_employee_id = params[:as_employee_id].blank? ?  nil  : params[:as_employee_id] 
      if @checking.update_attributes(params[:checking])
        flash[:notice] = "Le pointage a été modifié avec succès."
        redirect_to :action => "index" , :employee_id => @checking.employee_id, :date => @date , :as_employee_id => @as_employee_id
      else
        @employee = Employee.find(@checking.employee_id )    
         render :action => 'edit'
      end
   end

  #Cette méthode supprimer un objet Checking existant reposant sur le contenu de params[:id].
  #*  Si l'appel de méthode +destroy+ sur cet objet réussit, une &lfg;flash error&rfg; prend effet et l'action +index+ est appelée.
  #*  Si +destroy+ échoue, c'est l'action +index+ qui est appelée à la place.
  def destroy
    @checking = Checking.find(params[:id])
    unless @checking.destroy
      flash[:error] = "Une erreur est survenue à la suppression du pointage"
    else    
      flash[:notice] = "Le pointage a été supprimé avec succès."    
    end
    redirect_to :back
  end

end  
