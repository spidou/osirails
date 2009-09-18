module SuppliesManagerController
  # GET /'supplies'_manager
  def index
    @supply = (self.class.name.gsub("ManagerController","").singularize).constantize.new
    @supplies_categories_root = (self.class.name.gsub("ManagerController","").singularize+"Category").constantize.root
    @supplies_categories_root_child = (self.class.name.gsub("ManagerController","").singularize+"Category").constantize.root_child
    @supplies = (self.class.name.gsub("ManagerController","").singularize).constantize.activates
  end
end

