# Tokyo-cabinet-cache-store
require 'rufus/tokyo/tyrant'
module ActiveSupport
  module Cache
    # A cache store implementation which stores everything into Tokyo Cabinet 
    # key-value store data base
    class TokyoTyrantCacheStore < Store
      def initialize(options = {})                
        @data = Rufus::Tokyo::Tyrant.new( options[:host], options[:port].to_i)
        #@data.open(options[:file_path], TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)
        #@data.iterinit
      end

      def read(key, options = {})
        super
        record = @data[key]
        unless record.blank?
          data = Marshal.load(record)
          delete(key) if data[:expires_in] and data[:expires_in] < Time.now
          data[:data]
        else
          nil
        end
      end

      def write(key, data, options = {})
        super
        record = {:data => data}
        #record[:expires_in] = (Time.now + options[:expires_in] ) unless options[:expires_in].blank?
        @data[key] = Marshal.dump(record)
      end
      def keys
        @data.keys
      end
      def delete(key, options = {})
        super
        @data.delete(key)
      end

      def exist?(key,options = {})
        super
        @data.has_key?(key)
      end
      def clear
        @data.clear
      end
    end
  end
end
