class PasswordPoliciesController < ApplicationController
  
  def index
     $pattern = "{first_name,1}-{LAST_NAME}"
    # $pattern = params[:pattern]
    flash[:notice] = $pattern
  end
  
end
