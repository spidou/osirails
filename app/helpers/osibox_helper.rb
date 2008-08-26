module OsiboxHelper
  def osibox_init (options = {})
    configuration = {
      :url => {},
      :partial => nil,
      :wall_color => 'black',
      :wall_opacity => '0.8',
      :border_radius => '10px',
      :border_size => '8px',
      :border_type => 'solid',
      :border_color => 'black',
      :background_color => 'white',
      :scroll => false,
      :width => nil,
      :height => nil,
    }
    configuration.update(options)
    render :partial => "/osibox", :locals => {:options => configuration}
  end
  
  def osibox_open
    "<script type=\"text/javascript\">osibox_open();</script>"
  end
  
  def osibox_close
    "<script type=\"text/javascript\">osibox_close();</script>"    
  end
end