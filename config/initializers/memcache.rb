module ActiveSupport # http://stackoverflow.com/questions/3531588/memcached-as-an-object-store-in-rails
  module Cache
    class MemCacheStore
      # Fetching the entry from memcached
      # For some reason sometimes the classes are undefined
      #   First rescue: trying to constantize the class and try again.
      #   Second rescue, reload all the models
      #   Else raise the exception
      def fetch(key, options = {})
        retries = 2 
        begin
          super
        rescue ArgumentError, NameError => exc         
          if retries == 2
            if exc.message.match /undefined class\/module (.+)$/
              $1.constantize
            end
            retries -= 1
            retry          
          elsif retries == 1
            retries -= 1
            preload_models
            retry
          else 
            raise exc
          end
        end
      end

      private

      # There are errors sometimes like: undefined class module ClassName.
      # With this method we re-load every model
      def preload_models     
        #we need to reference the classes here so if coming from cache Marshal.load will find them     
        ActiveRecord::Base.connection.tables.each do |model|       
          begin       
            "#{model.classify}".constantize 
          rescue Exception       
          end     
        end       
      end
    end
  end
end
