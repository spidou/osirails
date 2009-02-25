Paperclip::Attachment.interpolations[:owner_class] = proc do |attachment, style|
  attachment.instance.has_document.class.name.tableize
end

Paperclip::Attachment.interpolations[:owner_id] = proc do |attachment, style|
  attachment.instance.has_document.id
end