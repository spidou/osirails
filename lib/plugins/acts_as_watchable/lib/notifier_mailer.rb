require "action_mailer" unless defined?(ActionMailer)

class NotificationMailer < ActionMailer::Base
  
  def footer
    html = []
    html <<   "<hr />"
    html <<   "<p><span class='footer'>"
    html <<   "<p>You have received this notification because you have either subscribed to it, or are involved in it."
    html <<   "<br />To change your notification preferences, please modify it in your osirails program.</p>"
    html <<   "</span></p>"
    html
  end
  
  def setup! path_template
    self.template_root = ActionMailer::Base.template_root = ActionController::Base.view_paths
    @body[:footer] = footer
    if path_template != ""
      self.mailer_name = path_template
    end
    
  end
  
  def notification_email(object, recipient, path_template = "")  
    self.setup! path_template
    @recipients = recipient
    @from = "Osirails <not-reply@mobius.re>"  
    @subject = "notification from your program"  
    @sent_on = Time.now
    @content_type = "text/html"
    @body[:object] = object
    template (object.class.name.tableize + "/" + self.mailer_name) if (self.mailer_name != "notification_mailer")
  end
  
end
