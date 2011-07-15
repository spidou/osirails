#Ce model renferme la logique associé au pointage (checking) à la base de données (MYSQL )
# Author::    Boisedu Olivier (boisedu.olivier.hotmail.fr)

class Checking < ActiveRecord::Base

  #  #  #  #  #  #  #
  #  Relations
  #Active Record crée une couche de correspondance relationnelle objet(Object relational mapping =>  ORM) par dessus ma base de données Checking.
  #Cela permet à Rails de communiquer avec la base de doonées à travers une interface orientée objet définie par des classes Actives Record.
  #Dans cette correspondance, les classes représentent des tables et les objets sont leurs enregistrements.
  #Notre base de données - relationnelle, comporte des relations:
  # de un à plusieurs "un employé possède beaucoup de pointage" => Employees have many checkings
  # "un pointage appartient à un employé'" => Checking belongs to employee
  #Pour Active Record belongs_to signifie que la table qui contient la clé étrangère appartient à la table qu'elle référence.
  #Une association un-vers-N 
  #Un employé peut avoir un nombre quelconque de pointage associées. 
  #Pour active record employee possède la collection d'objet fils => has many'
  belongs_to :employee
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

  has_permissions :as_business_object

  ABSENCE_MORNING = "morning"
  ABSENCE_AFTERNOON = "afternoon"
  ABSENCE_WHOLE_DAY = "whole_day"
  ABSENCE_nil = nil
  ABSENCE_PERIOD = [ABSENCE_nil,ABSENCE_MORNING,ABSENCE_AFTERNOON,ABSENCE_WHOLE_DAY] 


  #  #  #  #  #  #  #
  #Validation
  #Active Record est capable de valider le contenu de l'objet d'un modèle, notamment juste avant sa sauvegarde dans la base de données.
  #La méthode validate est invoqué pour toutes les opérations de sauvegarde dans la base de données

  #Le code qui suit montre comment s'assurer que la colonne nom d'utilisateur a toujours une valeur valide et que la date est unqiue pour tous les objets Checking nouvellement crées''
  #Quand une méthode de validation rencontre un problème, elle ajoute un message à la liste des erreurs du modèle en utilisant la méthode errors.add()
  #le premier paramètre est le nom de l'attribut mis en cause et le second est un message d'erreur

  #Active record offre un ensemble de méthodes d'assitance qui m'a permis d'ajouter ces règles au modèle.
  #Avec les méthodes de classe dont le nom débute par "validates_".Chaque méthode prend en paramètre une liste d'attributs:
  #  #  #  #  #  #  #


  #  Before Validation => éffacer les champs saisies selon l'absence
  before_validation :morning_absence_clean_morning_fields, :afternoon_absence_clean_afternoon_fields, :whole_day_absence_clean_all_fields , :unless => :absence_is_nil?

  #  #  #  #  #  #  #
  #Validation
  #  #  #  #  #  #  #

  #validates_uniqueness_of => Vérifie que les attributs sont uniques.
  #Je valide que un checking est unique pour un employee pour une date
  validates_uniqueness_of :date, :scope => :employee_id

  #validates_exclusion_of => Vérifie que des attributs ne font pas partie d'un ensemble de valeurs.
  #Je valide qu'on ne peut pas choisir l'option matin et la journée complète si il y a un congé le matin OU si je ne travail pasle matin
  validates_exclusion_of :absence_period , :in => [ABSENCE_MORNING,ABSENCE_WHOLE_DAY], :if => Proc.new { |a| a.is_morning_leave? || !a.scheduled_works_morning? }
  #Je valide qu'on ne peut pas choisir l'aprés midi' et la journée complète si il y a un congé l'aprés midi OU si je ne travail pas l'aprés midi
  validates_exclusion_of :absence_period, :in =>  [ABSENCE_AFTERNOON,ABSENCE_WHOLE_DAY],:if => Proc.new { |a| a.is_afternoon_leave? || !a.scheduled_works_afternoon? }

  #validates_inclusion_of => Vérifie que des attributs appartient à un ensemble de valeurs.
  #Je valide qu'on ne peut pas choisir autres chose que les valeurs proposer pour l'absence.
  validates_inclusion_of :absence_period, :in => ABSENCE_PERIOD ,:allow_blank => true 

  #validates_presence_of => Vérifie que des attributs ne sont pas vides.
  #Je valide que la date n'est ni égal à nil ni vide
  validates_presence_of :date 
  #Je valide que l'employee_id n'est ni égal à nil ni vide
  validates_presence_of :employee_id

  #Je valide que les horaires sont requis si il y a eu une modification du champs suivant ou qu'on ne travail pas à cette tranche horraire.
  #Je valide que morning_start doit être saisie si morning_end a été modifier ET que si on ne travail pas le matin
  validates_presence_of :morning_start, :if => Proc.new { |a| a.morning_end && !a.scheduled_works_morning? }
  #Je valide que morning_end doit être saisie si morning_start a été modifier ET que si on ne travail pas le matin
  validates_presence_of :morning_end, :if =>  Proc.new { |a| a.morning_start && !a.scheduled_works_morning? }
  #Je valide que afternoon_start doit être saisie si afternoon_end a été modifier ET que si on ne travail pas l' aprés midi
  validates_presence_of :afternoon_start, :if => Proc.new { |a| a.afternoon_end && !a.scheduled_works_afternoon? }
  #Je valide que afternoon_end doit être saisie si afternoon_start a été modifier ET que si on ne travail pas l' aprés midi
  validates_presence_of :afternoon_end, :if =>  Proc.new { |a| a.afternoon_start && !a.scheduled_works_afternoon? }

  #Je valide que les commentaires sont requis si il y a eu une modification des champs correspondant
  validates_presence_of :morning_start_comment, :if => :morning_start_modification?
  validates_presence_of :morning_end_comment, :if => :morning_end_modification? 
  validates_presence_of :afternoon_end_comment, :if => :afternoon_end_modification?
  validates_presence_of :afternoon_start_comment, :if => :afternoon_start_modification?
  validates_presence_of :absence_comment, :if => :absence_period


  #Je valide que les commentaires doivent être à nil si il y a pas eut de modification pour le champ correspondant?
  validates_inclusion_of :morning_start_comment, :in => [nil], :unless => :morning_start_modification?
  validates_inclusion_of :morning_end_comment, :in => [nil], :unless => :morning_end_modification? 
  validates_inclusion_of :afternoon_end_comment, :in => [nil], :unless => :afternoon_end_modification?
  validates_inclusion_of :afternoon_start_comment, :in => [nil], :unless => :afternoon_start_modification?


  #  #  #  #  #  #  #  #  #  #  #  #
  #Validation de date

  # Je valide que si la date du checking ne doit pas être une date futur / que la date du checking doit être absolument avant et/ou aujoud'hui.
  validates_date :date , :on_or_before => Date.today 

  #Je valide que si la date du checking corresponde aux dates des horaires remplis si ces champs ne sont pas vides.
  validates_date :morning_start, :equal_to => :date  , :if => :morning_start
  validates_date :morning_end,  :equal_to => :date  , :if => :morning_end 
  validates_date :afternoon_start , :equal_to => :date , :if => :afternoon_end
  validates_date :afternoon_end , :equal_to => :date , :if => :afternoon_end

  #  #  #  #  #  #  #  #  #  #  #  #
  #Validation heures

  #Je valide que si les heures saisies ne doivent pas être supèrieur à l'heure actuel Si il y a une modification des champs correspondant et que la date du checking équivaut à aujourd'hui
  validates_time :morning_start , :on_or_before => Time.now , :if  => Proc.new { |a| a.morning_start_modification? && (a.date == Date.today)}
  validates_time :morning_end , :on_or_before => Time.now , :if  => Proc.new { |a| a.morning_end_modification? && (a.date == Date.today)}
  validates_time :afternoon_start , :on_or_before => Time.now, :if  => Proc.new { |a| a.afternoon_start_modification? && (a.date == Date.today)}
  validates_time :afternoon_end , :on_or_before => Time.now , :if   =>  Proc.new { |a| a.afternoon_end_modification? && (a.date == Date.today)}

  #Validation que morning_end  > morning_start Si il y a une modification de morning_end OU de morning_start
  validates_time :morning_end , :after => :morning_start  , :if => Proc.new { |a| a.morning_end && a.morning_start }
  #Validation que   afternoon_start  >= morning_end Si il y a une modification de morning_end OU de afternoon_start
  validates_time :afternoon_start , :on_or_after => :morning_end, :if => Proc.new { |a| a.morning_end && a.afternoon_start }
  #Validation que afternoon_end  > afternoon_start Si il y a une modification de afternoon_end OU de afternoon_start
  validates_time :afternoon_end , :after => :afternoon_start, :if => Proc.new { |a| a.afternoon_end && a.afternoon_start }

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  Validation Customs 
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

  validate :validates_morning_leave, :validates_afternoon_leave, :validates_whole_day_leave 
  validate :validates_morning_absence, :validates_afternoon_absence, :validates_whole_day_absence 
  validate :validates_checking_is_complete , :unless => :is_whole_day_leave? 

  #  #  #  #  #  #  #  #  #  #  #
  #Validation Leave

  #Cette méthode permet de valider que l'utilisateur ne peut pas faire de pointage à un employé en congé le matin à la date du pointage.
  #*  Si l'employée est en congé le matin et que les champs de la matinée du formulaires ne sont pas vide.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_morning_leave
    if is_morning_leave? && morning_is_not_nil?
      errors.add(:morning_start, errors.generate_message(:morning_start, :leave_morning)) if self[:morning_start] && morning_start_modification? && !is_whole_day_leave?
      errors.add(:morning_end, errors.generate_message(:morning_end, :leave_morning)) if self[:morning_end] && morning_end_modification? && !is_whole_day_leave?
    end 
  end

  #Cette méthode permet de valider que l'utilisateur ne peut pas faire de pointage à un employé en congé l'aprés midi à la date du pointage.
  #*  Si l'employée est en congé l'aprés midi et que les champs de l'aprés midi du formulaires ne sont pas vide.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_afternoon_leave
    if is_afternoon_leave? && afternoon_is_not_nil?
      errors.add(:afternoon_start, errors.generate_message(:afternoon_start, :leave_afternoon)) if self[:afternoon_start] && afternoon_start_modification? && !is_whole_day_leave?
      errors.add(:afternoon_end, errors.generate_message(:afternoon_end, :leave_afternoon)) if self[:afternoon_end] && afternoon_end_modification? && !is_whole_day_leave?
    end 
  end

  #Cette méthode permet de valider que l'utilisateur ne peut pas faire de pointage à un employé en congé toute la journée à la date du pointage.
  #*  Si l'employée est en congé toute la journée.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_whole_day_leave
    if is_whole_day_leave? 
      errors.add_to_base(errors.generate_message(:base, :leave_whole_day))
    end 
  end

  #  #  #  #  #  #  #  #  #  #  #  #
  #Validation Absence

  #Cette méthode permet de valider que l'utilisateur ne peut pas modifier les horaires du matin à un employé est absent le matin.
  #*  Si l'employée est absent la matinée et que les champs de la matinée du formulaires ne sont pas vide.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_morning_absence
    if absence_is_morning? &&morning_is_not_nil?
      errors.add(:morning_start, errors.generate_message(:morning_start, :absence_morning)) if self[:morning_start] && morning_start_modification? && !absence_is_whole_day?
      errors.add(:morning_end, errors.generate_message(:morning_end, :absence_morning)) if self[:morning_end] && morning_end_modification? && !absence_is_whole_day?
    end 
  end

  #Cette méthode permet de valider que l'utilisateur ne peut pas modifier les horaires de l'aprés midi à un employé est absent l'aprés midi.
  #*  Si l'employée est absent l'aprés midi et que les champs de l'aprés midi du formulaires ne sont pas vide.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_afternoon_absence
    if  absence_is_afternoon? && afternoon_is_not_nil?
      errors.add(:afternoon_start, errors.generate_message(:afternoon_start, :absence_afternoon)) if self[:afternoon_start] && afternoon_start_modification? && !absence_is_whole_day?
      errors.add(:afternoon_end, errors.generate_message(:afternoon_end, :absence_afternoon)) if self[:afternoon_end] && afternoon_end_modification? && !absence_is_whole_day?
    end 
  end

  #Cette méthode permet de valider que l'utilisateur ne peut pas modifier les horaires de pointage à un employé est absent toute la journée.
  #*  Si l'employée est absent toute la journée et que tout les champs ne sont pas vide.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_whole_day_absence
    if absence_is_whole_day?  && (morning_is_not_nil? || afternoon_is_not_nil?)
      errors.add_to_base(errors.generate_message(:base, :absence_whole_day))
    end 
  end

  #  #  #  #  #  #  #  #  #  #  #  #
  #Validation Checking 

  #Cette méthode permet de valider que l'utilisateur ne peut a bien saisie au moins un champ avant de valider le pointage.
  #*  Si les champs : absence, des horaires de la matinée et de l'aprés midi sont vides.
  #*  Alors j'affiche un message d'erreurs et je ne valide pas le pointage.
  def validates_checking_is_complete
    if absence_is_nil? && self[:morning_start].nil? && self[:morning_end].nil? && self[:afternoon_start].nil? && self[:afternoon_end].nil?
      errors.add_to_base(errors.generate_message(:base, :complete_checking))
    end
  end

  #Cette méthode booléenne permet de savoir si les champs des horaires et commentaires du matin sont vide/null.
  def morning_is_not_nil?
    (!self[:morning_start].nil? || !self[:morning_start_comment].nil? || !self[:morning_end].nil? ||  !self[:morning_end_comment].nil?)
  end

  #Cette méthode booléenne permet de savoir si les champs des horaires et commentaires du matin sont vide/null.
  def afternoon_is_not_nil?
    (!self[:afternoon_start].nil? ||  !self[:afternoon_start_comment].nil? ||  !self[:afternoon_end].nil? ||  !self[:afternoon_end_comment].nil?)
  end


  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #
  #Getter

  #Cette méthode permet de modifier le getter d'origine de l'attribut morning_start 
  #*  Mon getter retourne la valeur de morning_start si elle a été définie/existante ou bien les horaires de services de l'arrivé au matin si elle existe pas.
  def morning_start
    self[:morning_start] || scheduled_morning_start_to_datetime
  end

  #Cette méthode permet de modifier le getter d'origine de l'attribut morning_end 
  #*  Mon getter retourne la valeur de morning_end si elle a été définie/existante ou bien les horaires de services de départ au matin 'si elle existe pas.
  def morning_end
    self[:morning_end] || scheduled_morning_end_to_datetime
  end

  #Cette méthode permet de modifier le getter d'origine de l'attribut afternoon_start 
  #*  Mon getter retourne la valeur de afternoon_start si elle a été définie/existante ou bien les horaires de services de l'arrivé de l'aprés midi  si elle existe pas.
  def afternoon_start
    self[:afternoon_start] || scheduled_afternoon_start_to_datetime
  end
       
  #Cette méthode permet de modifier le getter d'origine de l'attribut afternoon_end 
  #*  Mon getter retourne la valeur de afternoon_end si elle a été définie/existante ou bien les horaires de services de départ de l'aprés midi  'si elle existe pas.
  def afternoon_end
    self[:afternoon_end] || scheduled_afternoon_end_to_datetime
  end

  #  #  #  #  #
  #Getter v2

  #Cette méthode permet de créer un getter autre que celui d'origine
  #Mon getter retourne la valeur de morning_start convertie en float
  def morning_start_hours
    datetime_to_float_hours(morning_start)
  end

  #Cette méthode permet de créer un getter autre que celui d'origine
  #Mon getter retourne la valeur de morning_start convertie en float
  def morning_end_hours
    datetime_to_float_hours(morning_end)
  end

  #Cette méthode permet de créer un getter autre que celui d'origine
  #Mon getter retourne la valeur de morning_start convertie en float
  def afternoon_start_hours
    datetime_to_float_hours(afternoon_start)
  end

  #Cette méthode permet de créer un getter autre que celui d'origine
  #Mon getter retourne la valeur de morning_start convertie en float
  def afternoon_end_hours
    datetime_to_float_hours(afternoon_end)
  end

  #  #  #  #  #
  #Setter

  #Cette méthode permet de créer un autre setter autre que celui d'origine de l'attribut morning_start 
  #Mon setter reçoit la valeur du morning_start en float et la compare au heures de service de l'arrivé au matin
  #*  Si les horraires se correspondent OU que la valeur reçu est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre la valeur reçu convertie en datetime
  def morning_start_hours=(hours)
    self[:morning_start]  = hours.to_f == scheduled_morning_start || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end     

  #Cette méthode permet de créer un autre setter autre que celui d'origine de l'attribut morning_end
  #Mon setter reçoit la valeur du morning_end en float et la compare au heures de service de départ au matin
  #*  Si les horraires se correspondent OU que la valeur reçu est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre la valeur reçu convertie en datetime
  def morning_end_hours=(hours)
    self[:morning_end]  = hours.to_f == scheduled_morning_end || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end

  #Cette méthode permet de créer un autre setter autre que celui d'origine de l'attribut afternoon_start
  #Mon setter reçoit la valeur du morning_end en float et la compare au heures de service de d'arrivé l'aprés midi
  #*  Si les horraires se correspondent OU que la valeur reçu est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre la valeur reçu convertie en datetime
  def afternoon_start_hours=(hours)
    self[:afternoon_start]  = hours.to_f == scheduled_afternoon_start || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end

  #Cette méthode permet de créer un autre setter autre que celui d'origine de l'attribut afternoon_end
  #Mon setter reçoit la valeur du afternoon_end en float et la compare au heures de service de départ l'aprés midi
  #*  Si les horraires se correspondent OU que la valeur reçu est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre la valeur reçu convertie en datetime
  def afternoon_end_hours=(hours)
    self[:afternoon_end] = hours.to_f == scheduled_afternoon_end || hours.blank? ? nil : float_hours_to_datetime(hours.to_f)
  end

  #Cette méthode permet de modifier le setter d'origine de l'attribut morning_start_comment
  #Mon setter reçoit la valeur du morning_start_comment
  #*  Si le commentaire est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre le commentaire reçu en paramètre
  def morning_start_comment=(comment)
    self[:morning_start_comment]  = comment.blank? ? nil : comment
  end     

  #Cette méthode permet de modifier le setter d'origine de l'attribut morning_end_comment
  #Mon setter reçoit la valeur du morning_end_comment
  #*  Si le commentaire est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre le commentaire reçu en paramètre
  def morning_end_comment=(comment)
    self[:morning_end_comment]  = comment.blank? ? nil : comment
  end

  #Cette méthode permet de modifier le setter d'origine de l'attribut afternoon_start_comment
  #Mon setter reçoit la valeur du afternoon_start_comment
  #*  Si le commentaire est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre le commentaire reçu en paramètre
  def afternoon_start_comment=(comment)
    self[:afternoon_start_comment]  = comment.blank? ? nil : comment
  end

  #Cette méthode permet de modifier le setter d'origine de l'attribut afternoon_end_comment
  #Mon setter reçoit la valeur du afternoon_end_comment
  #*  Si le commentaire est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre le commentaire reçu en paramètre
  def afternoon_end_comment=(comment)
    self[:afternoon_end_comment]  = comment.blank? ? nil : comment
  end

  #Cette méthode permet de modifier le setter d'origine de l'attribut absence_period
  #Mon setter reçoit la valeur de absence_period
  #*  Si la valeur est vide 
  #*  Alors mon setter enregistre la valeur nil 
  #*  Sinon mon setter enregistre le choix de l'absence reçu en paramètre
  def absence_period=(absence)
    self[:absence_period] = absence.blank? ? nil : absence
  end


  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  #  #Méthodes de convertions  #  #  #

  #Cette méthode me permet de convertir une heure en float en datetime²
  #*  Si la valeur du float est nil 
  #*  alors je retourne nil 
  #*  Sinon si la valeur du float est pas nil 
  #*  Je retourne un datetime avec mon float convertis
  def float_hours_to_datetime(float)
    if float.nil?
      return nil     #DateTime.new(date.year,date.month,date.day)
    else
      hours = float.to_i    
      minutes = hours > 0 ? float%hours : float
      minutes = (minutes*60).to_i
     return DateTime.new(date.year,date.month,date.day,hours,minutes,0,DateTime.now.zone)
    end     
  end

  #Cette méthode me permet de retourné la valeur des horaires de services d'arrivé du matin de l'employé convertit en datetime
  def scheduled_morning_start_to_datetime
    float_hours_to_datetime(scheduled_morning_start)      
  end

  #Cette méthode me permet de retourné la valeur des horaires de services de départ du matin de l'employé convertit en datetime
  def scheduled_morning_end_to_datetime
    float_hours_to_datetime(scheduled_morning_end)
  end

  #Cette méthode me permet de retourné la valeur des horaires de services d'arrivé de l'aprés midi  de l'employé convertit en datetime
  def scheduled_afternoon_start_to_datetime
    float_hours_to_datetime(scheduled_afternoon_start)
  end

  #Cette méthode me permet de retourné la valeur des horaires de services de départ de l'aprés midi de l'employé convertit en datetime
  def scheduled_afternoon_end_to_datetime
    float_hours_to_datetime(scheduled_afternoon_end)
  end

  #Cette méthode me permet de convertir les heures d'un 'datetime en float
  #*  Si la valeur du datetime est nil 
  #*  alors je retourne nil 
  #*  Sinon si la valeur du datetime est pas nil 
  #*  Je retourne un float avec les horaires de mon datetime
  def datetime_to_float_hours(datetime)
    if datetime.nil?
      0.0
    else
      minutes =(datetime.min/0.6)/100
      hours = datetime.hour + minutes
    end  
  end

  #  def time_now_to_float    # TODO create this  method in model Time  => to_float_hours.
  #    datetime_to_float_hours(Time.now) 
  #  end

  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  #  #Méthodes de récupération de données  #  #  #

  #
  #  # Schedules
  #

  # => def wday
  # =>    date && date.wday
  # => end

  # => def schedule_hours
  # =>    @schedule = employee.schedule.find(:first, :conditions => ['date = ? AND service_id = ? ' , date,employee.service_id],:order 'date DESC')
  # =>    @schedule.schedule_hours.find(:first,:conditions => ['day = ?',wday])
  # => end


  #Cette méthode me permet de convertir le jour d'une date qui est numérique en chaine de caractère
  def week_day
    if date
      week_day = ["dimanche","lundi","mardi","mercredi","jeudi","vendredi","samedi"]
      return week_day[date.wday]
    end
  end

  #Cette méthode me permet de récupérer toutes les horaires de service de l'employé au jour du pointage
  def schedule_hours
    @schedule_hours ||= Schedule.find(:first , :conditions => ['day=? AND service_id=?',week_day, employee.service_id])
  end

  #
  #  #Récupération des heures de service
  #

  #Cette méthode me permet de retourner l'horaire de service d'arrivé au matin de l'employé si il y a des horaires de service
  def scheduled_morning_start
    schedule_hours && schedule_hours.morning_start  
  end
  
  #Cette méthode me permet de retourner l'horaire de service de départ au matin de l'employé si il y a des horaires de service
  def scheduled_morning_end
    schedule_hours && schedule_hours.morning_end
  end

  #Cette méthode me permet de retourner l'horaire de service d'arrivé de l'aprés midi de l'employé si il y a des horaires de service
  def scheduled_afternoon_start
    schedule_hours && schedule_hours.afternoon_start
  end

  #Cette méthode me permet de retourner l'horaire de service d'arrrivé de l'aprés midi de l'employé si il y a des horaires de service  
  def scheduled_afternoon_end
    schedule_hours && schedule_hours.afternoon_end
  end

  #
  #  #Récupération totaux d'heures de service
  #

  #Cette méthode me permet de retourner le total d'heures de service de la matinée à éffectuer par l'employé si il y a des heures de service
  def scheduled_morning_hours
    schedule_hours && schedule_hours.scheduled_morning_hours
  end

  #Cette méthode me permet de retourner le total d'heures de service de l'aprés midi à éffectuer par l'employé si il y a des heures de service
  def scheduled_afternoon_hours
   schedule_hours &&  schedule_hours.scheduled_afternoon_hours
  end

  #Cette méthode me permet de retourner le total d'heures de service de la journée à éffectuer par l'employé si il y a des heures de service
  def scheduled_whole_day_hours
    schedule_hours && schedule_hours.scheduled_total_hours
  end

  #
  #  #Récupération des indications de travail
  #

  #Cette méthode booléenne me permet de savoir si l'employé possède des heures de service pour la matinée
  def scheduled_works_morning?
    schedule_hours && schedule_hours.works_morning?
  end

  #Cette méthode booléenne me permet de savoir si l'employé possède des heures de service pour l'apré midi 
  def scheduled_works_afternoon?
    schedule_hours && schedule_hours.works_afternoon?
  end

  #Cette méthode booléenne me permet de savoir si l'employé possède des heures de service pour la journée complète
  def scheduled_works_whole_day?
    schedule_hours && schedule_hours.works_whole_day?
  end

  #Cette méthode booléenne me permet de savoir si l'employé possède des heures de service pour la demie journée uniquement
  def scheduled_works_today?
    schedule_hours && schedule_hours.works_today?
  end

  #
  #  # Leave
  #

  #Cette méthode me permet de récupérer tout les congé de l'employé correspondant à la date du pointage
  def leaves
    @leaves ||= Leave.find(:all,:conditions => ['start_date <= ? AND end_date >= ? AND employee_id = ?', date,date,employee_id], :order => 'start_date ASC')
  end

  #Cette méthode booléenne me permet de savoir si l'employé possède des congés pour la matinée
  def is_morning_leave?
    leaves.each do |leave|
        return true if date != leave.start_date
        return true if date == leave.start_date && !leave.start_half 
      end
    return false
  end

  #Cette méthode booléenne me permet de savoir si l'employé possède des congés pour l'aprés midi
  def is_afternoon_leave?
    leaves.each do |leave|
        return true if date != leave.end_date
        return true if date == leave.end_date && !leave.end_half 
      end
    return false
  end

  #Cette méthode booléenne me permet de savoir si l'employé possède des congés pour la journée complète
  def is_whole_day_leave?
    is_morning_leave? && is_afternoon_leave?
  end 

  #Cette méthode booléenne de savoir si l'employé est en congé aujourd'hui
  def is_leave_today?
    is_whole_day_leave? || is_morning_leave? || is_afternoon_leave? 
  end

  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  #  #Méthodes booléenne absence  #  #

  #Cette méthode booléenne de savoir si l'employé est absent le matin 
  def absence_is_morning?
    absence_period == ABSENCE_MORNING
  end

  #Cette méthode booléenne de savoir si l'employé est absent l'aprés midi
  def absence_is_afternoon?
    absence_period == ABSENCE_AFTERNOON
  end

  #Cette méthode booléenne de savoir si l'employé est absent la journée complète
  def absence_is_whole_day?
    absence_period == ABSENCE_WHOLE_DAY
  end

  #Cette méthode booléenne de savoir si l'employé n'est pas absent
  def absence_is_nil?
      absence_period == ABSENCE_nil
  end

  #Cette méthode booléenne de savoir si l'employé absent aujourd'hui
  def is_absence_today?
    absence_is_whole_day? || absence_is_morning? || absence_is_afternoon? 
  end

  #
  #  # Absence choisis ok 
  #

  #Cette méthode permet d'éffacer les champs saisies par l'utilisateur pour la matinée si l'employé est indiqué absent le matin 
  def morning_absence_clean_morning_fields
    if absence_is_morning?
      clean_morning_fields
    end
  end

  #Cette méthode permet d'éffacer les champs saisies par l'utilisateur pour l'aprés midi si l'employé est indiqué absent l'aprés midi
  def afternoon_absence_clean_afternoon_fields  
    if absence_is_afternoon?
      clean_afternoon_fields
    end
  end

  #Cette méthode permet d'éffacer tout les champs saisies par l'utilisateur si l'employé est indiqué absent la journée complète
  def whole_day_absence_clean_all_fields
    if absence_is_whole_day?
      clean_morning_fields
      clean_afternoon_fields
    end
  end

  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  #  #Méthodes booléenne présence  #  #

  #
  #  # Modification ?
  #

  #Cette méthode booléenne me permet de savoir si le champs morning_start du formulaire a été modifié
  def morning_start_modification?
    !self[:morning_start].nil? 
  end

  #Cette méthode booléenne me permet de savoir si le champs morning_end du formulaire a été modifié
  def morning_end_modification?
    !self[:morning_end].nil?
  end
  
  #Cette méthode booléenne me permet de savoir si le champs afternoon_start du formulaire a été modifié
  def afternoon_start_modification?
    !self[:afternoon_start].nil?
  end

  #Cette méthode booléenne me permet de savoir si le champs afternoon_end du formulaire a été modifié
  def afternoon_end_modification?
    !self[:afternoon_end].nil?  
  end


  #
  #  # Heures sup ?
  #

  #Cette méthode booléenne me permet de savoir si le champs morning_start sasie par l'utilisateur sont des heures supp pour le pointage
  #*  Si il y a eut modification du champs d'arrivé pour la matinée ET que il y a des heures de services définies pour le matin 
  #*  Alors on retourne vraie Si les heures d'arrivé du matin sont supèrieur aux horaires saisies par l'utilisateur 
  def morning_start_is_overtime?
    if morning_start_modification? && scheduled_works_morning?
       scheduled_morning_start_to_datetime > float_hours_to_datetime(morning_start_hours)
    else
      false
    end
  end
  
  #Cette méthode booléenne me permet de savoir si le champs morning_end saisie par l'utilisateur sont des heures supp pour le pointage
  #*  Si il y a eut modification du champs de départ pour la matinée ET que il y a des heures de services définies pour le matin 
  #*  Alors on retourne vraie Si les heures de départ du matin sont infèrieures aux horaires saisies par l'utilisateur 
  def morning_end_is_overtime?
    if morning_end_modification? && scheduled_works_morning?
      scheduled_morning_end_to_datetime < float_hours_to_datetime(morning_end_hours)
    else
      false
    end
  end

  #Cette méthode booléenne me permet de savoir si le champs afternoon_start saisie par l'utilisateur sont des heures supp pour le pointage
  #*  Si il y a eut modification du champs d'arrivé pour l'aprés midi ET que il y a des heures de services définies pour l'aprés midi
  #*  Alors on retourne vraie Si les heures d'arrivé l'aprés midi sont supèrieur aux horaires saisies par l'utilisateur 
  def afternoon_start_is_overtime?
    if afternoon_start_modification? && scheduled_works_afternoon?
      scheduled_afternoon_start_to_datetime >  float_hours_to_datetime(afternoon_start_hours)
    else
      false
    end
  end  

  #Cette méthode booléenne me permet de savoir si le champs afternoon_end saisie par l'utilisateur sont des heures supp pour le pointage
  #*  Si il y a eut modification du champs de départ pour l'aprés midi ET que il y a des heures de services définies pour l'aprés midi
  #*  Alors on retourne vraie Si les heures de départ l'aprés midi sont infèrieures aux horaires saisies par l'utilisateur 
  def afternoon_end_is_overtime?
    if afternoon_end_modification? && scheduled_works_afternoon?
      scheduled_afternoon_end_to_datetime < float_hours_to_datetime(afternoon_end_hours)
    else
      false
    end
  end

  #
  #  # Heures retard ?
  #

  #Cette méthode booléenne me permet de savoir si le champs morning_start saisie par l'utilisateur sont des heures de retard pour le pointage
  #*  Si il y a eut modification du champs d'arrivé pour la matinée midi ET que il y a des heures de services définies pour la matinée
  #*  Alors on retourne vraie Si les heures d'arrivé du matin sont infèrieures aux horaires saisies par l'utilisateur
  def morning_start_delay?
    if morning_start_modification? && scheduled_works_morning?
      scheduled_morning_start_to_datetime < float_hours_to_datetime(morning_start_hours)
    else
      false
    end
  end

  #Cette méthode booléenne me permet de savoir si le champs morning_end saisie par l'utilisateur sont des heures de retard pour le pointage
  #*  Si il y a eut modification du champs de départ pour la matinée ET que il y a des heures de services définies pour la matinée
  #*  Alors on retourne vraie Si les heures départ du matin sont supèrieur aux horaires saisies par l'utilisateur
  def morning_end_delay?
    if morning_end_modification? && scheduled_works_morning?
      scheduled_morning_end_to_datetime >  float_hours_to_datetime(morning_end_hours)
    else
      false
    end
  end

  #Cette méthode booléenne me permet de savoir si le champs afternoon_start saisie par l'utilisateur sont des heures de retard pour le pointage
  #*  Si il y a eut modification du champs d'arrivé pour l'aprés midi ET que il y a des heures de services définies pour l'aprés midi
  #*  Alors on retourne vraie Si les heures d'arrivé de l'aprés midi sont infèrieures aux horaires saisies par l'utilisateur
  def afternoon_start_delay?
    if afternoon_start_modification? && scheduled_works_afternoon?
      scheduled_afternoon_start_to_datetime < float_hours_to_datetime(afternoon_start_hours)
    else
      false
    end
  end  

  #Cette méthode booléenne me permet de savoir si le champs afternoon_end saisie par l'utilisateur sont des heures de retard pour le pointage
  #*  Si il y a eut modification du champs de départ pour l'aprés midi ET que il y a des heures de services définies pour l'aprés midi
  #*  Alors on retourne vraie Si les heures de départ de l'aprés midi sont supèrieur aux horaires saisies par l'utilisateur
  def afternoon_end_delay?
    if afternoon_end_modification? && scheduled_works_afternoon?
      scheduled_afternoon_end_to_datetime > float_hours_to_datetime(afternoon_end_hours)
    else
      false
    end
  end


  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  #  #Méthodes pour caluler les heures  #  #  #

  #
  #  # Calcul des heures éffectuer par tranche horaires
  #

  #Cette méthode permet de retourner la différence d'heures qu'il y a entre les horaires de service d'arrivé du matin et ceux saisies par l'utilisateur
  #*  Si il y a eut modification du champs de d'arrivé du matin  ET que il y a des heures de services pour cet tranche horaire
  #*  Alors on retourne la différence d'heures entre ces deux valeurs
  def working_morning_start_hours
    if morning_start_modification? && scheduled_morning_start
      worked_hours = morning_start_hours - scheduled_morning_start
      worked_hours < 0 ?  worked_hours * -1 : worked_hours
    end  
  end

  #Cette méthode permet de retourner la différence d'heures qu'il y a entre les horaires de service de départ du matin et ceux saisies par l'utilisateur
  #*  Si il y a eut modification du champs de départ du matin  ET que il y a des heures de services pour cet tranche horaire
  #*  Alors on retourne la différence d'heures entre ces deux valeurs
  def working_morning_end_hours
    if morning_end_modification? && scheduled_morning_end
      worked_hours = morning_end_hours - scheduled_morning_end
      worked_hours < 0 ?  worked_hours * -1 : worked_hours
    end    
  end

  #Cette méthode permet de retourner la différence d'heures qu'il y a entre les horaires de service de d'arrivé de l'aprés midi et ceux saisies par l'utilisateur
  #*  Si il y a eut modification du champs de d'arrivé de l'aprés midi  ET que il y a des heures de services pour cet tranche horaire
  #*  Alors on retourne la différence d'heures entre ces deux valeurs
  def working_afternoon_start_hours
    if afternoon_start_modification? && scheduled_afternoon_start
      worked_hours = afternoon_start_hours - scheduled_afternoon_start
      worked_hours < 0 ?  worked_hours * -1 : worked_hours
    end    
  end

  #Cette méthode permet de retourner la différence d'heures qu'il y a entre les horaires de service de départ de l'aprés midi et ceux saisies par l'utilisateur
  #*  Si il y a eut modification du champs de départ de l'aprés midi  ET que il y a des heures de services pour cet tranche horaire
  #*  Alors on retourne la différence d'heures entre ces deux valeurs
  def working_afternoon_end_hours
    if afternoon_end_modification? && scheduled_afternoon_end
      worked_hours = afternoon_end_hours - scheduled_afternoon_end
      worked_hours < 0 ?  worked_hours * -1 : worked_hours
    end    
  end

  #Cette méthode permet de retourner le total d'heures éffectuer lors de la matinée du pointage
  #*  Si il y a des heures pointées le matin 
  #*  Alors on retourne la différence d'heures éffecteur au matin 
  #* Sinon j'ai pas fait d'heures et je retourne zéro
  def working_morning_hours
     worked_morning?  ?  morning_end_hours - morning_start_hours : 0
  end

  #Cette méthode permet de retourner le total d'heures éffectuer lors de l'aprés midi du pointage
  #*  Si il y a des heures pointées l'aprés midi
  #*  Alors on retourne la différence d'heures éffecteur au matin 
  #* Sinon j'ai pas fait d'heures et je retourne zéro
  def working_afternoon_hours
      worked_afternoon? ? afternoon_end_hours - afternoon_start_hours : 0
  end

  #Cette méthode permet de retourner le total d'heures éffectuer lors de la journée du pointage
  def  working_whole_day_hours
    working_morning_hours + working_afternoon_hours
  end

  #
  #  # Calcul totaux checking hours
  #

  #Cette méthode booléenne me permet de savoir 
  #*  Si l'employé possède des heures définies la matinée
  #*  ET que l'employée n'est pas absent le matin ET toute la journée
  #*  ET que l'employée n'est pas en congé le matin ET toute la journée
  def worked_morning?  
    morning_start && morning_end  && !absence_is_morning?  && !absence_is_whole_day? && !is_morning_leave? && !is_whole_day_leave?
  end

  #Cette méthode booléenne me permet de savoir 
  #*  Si l'employé possède des heures définies l'aprés midi
  #*  ET que l'employée n'est pas absent l'aprés midi ET toute la journée
  #*  ET que l'employée n'est pas en congé l'aprés midi ET toute la journée
  def worked_afternoon?  
     afternoon_start && afternoon_end && !absence_is_afternoon? && !absence_is_whole_day? && !is_afternoon_leave? && !is_whole_day_leave?
  end


  #Cette méthode booléenne me permet de savoir 
  #*  Si pour le pointage de l'employé a été pointé pour toute la journée
  def worked_whole_day?  
    worked_morning?  && worked_afternoon?  
  end

  #Cette méthode booléenne me permet de savoir 
  #*  Si pour le pointage de l'employé a  été pointé soit la matinée ou soit l'aprés midi 
  def worked_today?  
    worked_morning?  || worked_afternoon?  
  end


  #
  #  # Calcul totaux schedule hours
  #

  #Cette méthode permet de retourner le total d'heures de services exact à comparaitre selon que l'employé a été en congé ou pas
  #*  SI l'employé est en congé toute la journée le total d'heures de service éffectuer est de zéro
  #*  SI l'employé est en congé l'aprés midi le total d'heures de service éffectuer est ceux de l'aprés midi 
  #*  SI l'employé est en congé la matinée le total d'heures de service éffectuer est ceux de la matinée
  #*  SINON le total d'heures de service éffectuer est ceux de toute la journée
  def  scheduled_total_hours
    if is_whole_day_leave?
        0  
    elsif is_morning_leave? 
       scheduled_afternoon_hours
    elsif is_afternoon_leave? 
      scheduled_morning_hours
    else
      scheduled_whole_day_hours
    end
  end

  #
  #  # Calcul balance entre schedule et checking hours
  #
  
  #Cette méthode booléenne me permet de retourner la diffèrence d'heures éffectuer par l'employée pour une journée 
  #SI il possède des heures de service
  def balance_worked_hours
    if schedule_hours 
      working_whole_day_hours - scheduled_total_hours
    end
  end
  #------------------------------------------------------------------------------------------------------------------------------------  #

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  #  #Méthodes private pour éffacer les champs  #  #  #

  private
    def clean_morning_fields
      self[:morning_start]  = nil
      self[:morning_start_comment] = nil
      self[:morning_end] = nil
      self[:morning_end_comment] = nil
    end

    def clean_afternoon_fields
      self[:afternoon_start]  = nil
      self[:afternoon_start_comment] = nil
      self[:afternoon_end] = nil
      self[:afternoon_end_comment] = nil
    end     

end
