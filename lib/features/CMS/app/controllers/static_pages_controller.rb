class StaticPagesController < ApplicationController
  def list
    @static_pages = StaticPage.find(:all, :conditions => ["type = ?", "StaticPage"])
  end

end
