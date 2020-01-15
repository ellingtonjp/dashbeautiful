require 'httparty'

module Meraki
  # description TODO
  class API
    attr_reader :key

    def initialize(key, requestor: HTTParty)
      @key = key
      @base_url = 'https://api.meraki.com/api/v0'
      @headers = {
        'X-Cisco-Meraki-API-Key' => key,
        'Content-Type' => 'application/json'
      }
      @options = {
        headers: @headers
      }
      @requestor = requestor
    end

    def organizations
      get('/organizations').map { |h| symbolize_keys(h) }
    end

    def update_organization(organization_id, body)
      valid_keys = %i[name]

      raise ArgumentError, 'body must be a hash' unless body.is_a? Hash
      raise ArgumentError, 'body cannot be empty' if body.empty?

      put("/organizations/#{organization_id}", valid_keys: valid_keys, body: body)
    end

    def networks(organization_id)
      get("/organizations/#{organization_id}/networks").map { |h| symbolize_keys(h) }
    end

    def devices(network_id)
      get("/networks/#{network_id}/devices").map { |h| symbolize_keys(h) }
    end

    def get(path, **options)
      options = @options.merge(options)
      response = @requestor.get(@base_url + path, options)

      raise APIRequestError if response.code != 200

      response
    end

    def put(path, valid_keys:, body:, **options)
      raise ArgumentError, "body key can only be #{valid_keys}" unless valid_keys.all? { |key| body.key? key }

      options = @options.merge(options)
      options = options.merge(body: body.to_json)
      response = @requestor.put(@base_url + path, options)

      raise APIRequestError if response.code != 200

      response
    end

    private

    def symbolize_keys(hash)
      Hash[hash.map { |(k, v)| [k.to_sym, v] }]
    end
  end
end
