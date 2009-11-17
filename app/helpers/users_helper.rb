module UsersHelper
  def contextual_search_for_user
    contextual_search("User", ["*", "roles.name"])
  end
  
  def get_headers
    result = []
    result << "Nom du compte utilisateur"
    result << "Compte activé ?"
    result << "Dernière connexion"
    result << "Actions"
  end
  
  def get_rows(user)
    result = []
    result << link_to(user.username, user)
    result << (user.enabled ? "Oui" : "Non")
    result << (user.last_connection.nil? ? "Jamais connecté" : user.last_connection.to_humanized_datetime)
    result << "#{user_link(user, :link_text => "")} #{edit_user_link(user, :link_text => "")} #{delete_user_link(user, :link_text => "")}"
  end
end
