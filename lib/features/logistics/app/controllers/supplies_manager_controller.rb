module SuppliesManagerController
  # GET /'supplies'_manager
  def index
    @supply = (self.class.name.gsub("ManagerController","").singularize).constantize.new
    @supplies_categories_root = (params[:inactives]=="true" ? (self.class.name.gsub("ManagerController","").singularize+"Category").constantize.root_including_inactives : (self.class.name.gsub("ManagerController","").singularize+"Category").constantize.root)
    @categories = (params[:inactives]=="true" ? (self.class.name.gsub("ManagerController","").singularize+"Category").constantize.find(:all) : (self.class.name.gsub("ManagerController","").singularize+"Category").constantize.was_enabled_at)
    @supplies = (params[:inactives]=="true" ? (self.class.name.gsub("ManagerController","").singularize).constantize.find(:all) : (self.class.name.gsub("ManagerController","").singularize).constantize.was_enabled_at)
  end
end

