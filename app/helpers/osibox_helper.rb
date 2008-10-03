module OsiboxHelper
  def osibox_init (options = {})
    configuration = {
      :close_button => true,
      :id => 1,
      :url => {},
      :partial => nil,
      :locals => nil,
      :wall_color => 'black',
      :wall_opacity => '0.8',
      :border_radius => '10px',
      :border_size => '8px',
      :border_type => 'solid',
      :border_color => 'black',
      :background_color => 'white',
      :scroll => 'auto',
      :width => nil,
      :height => nil,
    }
    configuration.update(options)
    render :partial => "share/osibox", :locals => {:options => configuration}
  end
  
  def osibox_open(id = 1)
    "<script type=\"text/javascript\">osibox_open(#{id});</script>"
  end
  
  def osibox_close()
    "<script type=\"text/javascript\">osibox_close();</script>"    
  end
end