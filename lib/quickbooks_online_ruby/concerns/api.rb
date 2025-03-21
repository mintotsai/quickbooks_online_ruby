require 'uri'
require 'quickbooks_online_ruby/concerns/verbs'

module QuickbooksOnlineRuby
  module Concerns
    module API
      extend QuickbooksOnlineRuby::Concerns::Verbs

      # Public: Helper methods for performing arbitrary actions against the API using
      # various HTTP verbs.
      #
      # Examples
      #
      #   # Perform a get request
      #   client.get '/v3/company/<realmID>/payment/<paymentId>'
      #   client.api_get 'payment', <paymentId>
      #
      #   # Perform a post request
      #   client.post '/v3/company/<realmID>/payment', { ... }
      #   client.api_post 'payment', { ... }
      #
      #   # Perform a delete request
      #   client.delete '/v3/company/<realmID>/payment?operation=delete'
      #   client.api_delete 'payment', { ... }
      #
      # Returns the Faraday::Response.
      define_verbs :get, :post, :delete

      # Public: Insert a new record.
      #
      # qbo_object - String name of the sobject.
      # attrs   - Hash of attributes to set on the new record.
      #
      # Examples
      #
      #   # Add a new account
      #   client.create('customer', attrs)
      #
      # Returns the newly created qbo_object.
      # Returns false if something bad happens.
      def create(*args)
        create!(*args)
      rescue *exceptions
        false
      end
      alias insert create

      # Public: Insert a new record.
      #
      # qbo_object - String name of the sobject.
      # attrs   - Hash of attributes to set on the new record.
      #
      # Examples
      #
      #   # Add a new account
      #   client.create!('customer', attrs)
      #
      # Returns the newly created qbo_object.
      # Raises exceptions if an error is returned from Quickbooks.
      def create!(qbo_object, attrs)
        api_post("#{qbo_object}", attrs).body
      end
      alias insert! create!

      # Public: Update a record.
      #
      # qbo_object - String name of the sobject.
      # attrs   - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Update the Customer
      #   client.update('customer', attrs)
      #
      # Returns true if the qbo_object was successfully updated.
      # Returns false if there was an error.
      def update(*args)
        update!(*args)
      rescue *exceptions
        false
      end

      # Public: Update a record.
      #
      # qbo_object - String name of the sobject.
      # attrs      - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Update the Customer
      #   client.update!('customer', attrs)
      #
      # Returns true if the qbo_object was successfully updated.
      # Raises an exception if an error is returned from Quickbooks.
      def update!(qbo_object, attrs)
        api_post("#{qbo_object}", attrs).body
      end

      # Public: Delete a record.
      #
      # qbo_object - String name of the object.
      # attrs      - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Delete the Customer
      #   client.delete('customer', attrs)
      #
      # Returns true if the qbo_object was successfully deleted.
      # Returns false if an error is returned from Quickbooks.
      def delete(*args)
        delete!(*args)
      rescue *exceptions
        false
      end

      # Public: Delete a record.
      #
      # qbo_object - String name of the object.
      # attrs      - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Delete the Customer
      #   client.delete!('Account', attrs)
      #
      # Returns true of the qbo_object was successfully deleted.
      # Raises an exception if an error is returned from Quickbooks.
      def delete!(qbo_object, attrs)
        api_post("#{qbo_object}?operation=delete", attrs).body
      end

      # Public: Void a record.
      #
      # qbo_object - String name of the object.
      # attrs      - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # attrs the Customer
      #   client.void('payment', attrs)
      #
      # Returns true if the qbo_object was successfully voided.
      # Returns false if an error is returned from Quickbooks.
      def void(*args)
        void!(*args)
      rescue *exceptions
        false
      end

      # Public: Void a record.
      #
      # qbo_object - String name of the object.
      # attrs      - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Void the Customer
      #   client.void!('payment', attrs)
      #
      # Returns true of the qbo_object was successfully voided.
      # Raises an exception if an error is returned from Quickbooks.
      def void!(qbo_object, attrs)
        if "invoice".eql? qbo_object
          api_post("#{qbo_object}?operation=void", attrs).body
        else
          api_post("#{qbo_object}?include=void", attrs).body
        end
      end

      # Public: Reads a single record and returns all fields.
      #
      # qbo_object - The String name of the sobject.
      # id         - The id of the record. If field is specified, id should be the id
      #              of the external field.
      #
      # Returns record.
      def read(qbo_object, id)
        url = "#{qbo_object}/#{id}"
        api_get(url).body
      end

      # Public: Query a single record and returns all fields.
      #
      # qbo_object - The String name of the sobject.
      # id         - The id of the record. If field is specified, id should be the id
      #              of the external field.
      #
      # Returns the results of the query.
      def query(query)
        url = "query?query=#{URI.encode_www_form_component(query)}"
        api_get(url).body
      end

      private

      # Internal: Returns a path to an api endpoint
      #
      # Examples
      #
      #   api_path('qbo_objects')
      #   # => '/v3/company/<realm_id>/customer'
      def api_path(path)
        "/v3/company/#{options[:realm_id]}/#{path}"
      end

      # Internal: Errors that should be rescued from in non-bang methods
      def exceptions
        [Faraday::Error::ClientError]
      end
    end
  end
end
