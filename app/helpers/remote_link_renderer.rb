class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    @method_for_remote_link = options.delete(:method_for_remote_link) || :get
    
    super
  end

protected
  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, {:url => url_for(page), :method => @method_for_remote_link}.merge(@remote))
  end
end
