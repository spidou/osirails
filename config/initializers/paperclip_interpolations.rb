Paperclip::Attachment.interpolations[:owner_class] = proc do |attachment, style|
  attachment.instance.has_document.class.name.tableize
end

Paperclip::Attachment.interpolations[:owner_id] = proc do |attachment, style|
  attachment.instance.has_document_id
end

Paperclip::Attachment.interpolations[:mimetype] = proc do |attachment, style|
  content_type = attachment.instance.send(attachment.name.to_s + "_content_type")
  content_type.nil? ? "UnknownType" : content_type.camelize
end