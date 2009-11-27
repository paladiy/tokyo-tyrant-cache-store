# Tokyo-cabinet-cache-store
require 'rufus/tokyo/tyrant'
module ActiveSupport
  module Cache
    # A cache store implementation which stores everything into Tokyo Cabinet 
    # key-value store data base
    class TokyoTyrantCacheStore < Store
      def initialize(options = {})                        
        @options = {
          :host => '127.0.0.1',
          :port => '1978',
          :namespace => 'tokyo_tyrant'
        }.merge(options)        
        @data = Rufus::Tokyo::Tyrant.new( @options[:host], @options[:port].to_i)
        #@data.open(options[:file_path], TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)
        #@data.iterinit
      end

      def read(key, options = {})
        super
        record = @data[key_with_namespace(key)]
        unless record.blank?
          data = Marshal.load(record)
          delete(key_with_namespace(key)) if data[:expires_in] and data[:expires_in] < Time.now
          data[:data]
        else
          nil
        end
      end

      def write(key, data, options = {})
        super
        record = {:data => data}
        #record[:expires_in] = (Time.now + options[:expires_in] ) unless options[:expires_in].blank?
        @data[key_with_namespace(key)] = Marshal.dump(record)
      end
      def keys
        @data.keys
      end
      def delete(key, options = {})
        super
        @data.delete(key_with_namespace(key))
      end

      def exist?(key,options = {})
        super
        @data.has_key?(key_with_namespace(key))
      end
      def clear
        @data.clear
      end
      private
      def key_with_namespace(key)        
        "#{@options[:namespace]}_#{key}"
      end
    end
  end
end
