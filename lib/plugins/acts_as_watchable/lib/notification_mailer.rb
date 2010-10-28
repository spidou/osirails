require 'action_mailer' unless defined?(ActionMailer)

class NotificationMailer < ActionMailer::Base
  layout 'default_notification'
  
  attr_accessor :full_template_path
  
  def notification_email(object, recipient, template_path)
    @object = object
    setup!(template_path)
    
    @recipients = recipient
    @subject = "[Notification] #{object.class.human_name} - #{template_path.to_s.humanize}" #TODO use i18n to store translation for mailer functions
  end
  
  private
    def setup!(template_path)
      #### TODO can't we do that only once ?
      self.template_root = ActionMailer::Base.template_root = ActionController::Base.view_paths
      ####
      
      @from = "Osirails Project <noreply@spidou.com>"  
      @content_type = "text/html"
      @charset = "utf-8"
      #@sent_on = Time.zone.now #FIXME is this really useful?
      
      if ActsAsWatchable::DEFAULT_NOTIFICATION_FUNCTIONS.include?(template_path)
        template("notification_mailer/#{template_path}")
      else
        template(@object.class.name.tableize + "/" + template_path.to_s)
      end
    end
end
