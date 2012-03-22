module Footnotes
  module Notes
    class LoadingTimeNote < AbstractNote
      def initialize(controller)
        @loading_time_note_start_time = Time.now
      end
      
      def title
        loading_time = Time.now - @loading_time_note_start_time
        color = time_color(loading_time)
        
        "Page rendered in <span style=\"background-color:#{color}\">#{loading_time}</span> seconds"
      end

      def row
        :show
      end
      
      private
        def time_color(time)
          time > 1 ? '#ff8686' : 'inherit'
        end
    end
  end
end
