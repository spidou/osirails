class StaticPage < Page
  serialize :contributors
  
  belongs_to :parent_page, :class_name =>"StaticPage", :foreign_key => "parent_id"
  validates_presence_of :title
end