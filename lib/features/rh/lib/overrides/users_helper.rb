require_dependency 'app/helpers/users_helper'

module UsersHelper
  alias_method :get_headers_without_rh_override, :get_headers

  def get_headers
    result = ["Employ&eacute;"]
    result += get_headers_without_rh_override
  end
  
  alias_method :get_rows_without_rh_override, :get_rows

  def get_rows(user)
    result = [ (user.employee.nil? ? "" : user.employee.fullname) ]
    result += get_rows_without_rh_override(user)
  end
end
