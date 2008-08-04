class AdminMailer < ActionMailer::Base  
  def notice_admin_lost_password(username)
    recipients  "lanbenj@yahoo.fr"
    from        "server@osirails.net"
    subject     "An user lost his password"
    body        "The user: " + username + " has lost his password"
  end
  
  def notice_user_lost_password(username)
    recipients  "lanbenj@yahoo.fr"
    from        "server@osirails.net"
    subject     "Notice for admin"
    body        :username => username # FIXME Add features views paths for ActionMailer
  end
end
