class AdminMailer < ActionMailer::Base
  def notice_admin_lost_password(username)
    recipients  "admin@osirails.net"
    from        "server@osirails.net"
    subject     "An user lost his password"
    body        "The user: " + username + " has lost his password"
  end
  
  def notice_user_lost_password(username)
    recipients  "user@osirails.net" # 
    from        "server@osirails.net"
    subject     "Notice for admin"
    body        :username => username # FIXME Template is missing, when we send the mail
  end
end
