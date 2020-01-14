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

    def networks(organization_id)
      get("/organizations/#{organization_id}/networks").map { |h| symbolize_keys(h) }
    end

    def devices(network_id)
      get("/networks/#{network_id}/devices").map { |h| symbolize_keys(h) }
    end

    def get(path, **options)
      options = @options.merge(options)
      @requestor.get(@base_url + path, options)
    end

    def put(path, body:, **options)
      options = @options.merge(options)
      options = options.merge(body: body.to_json)
      @requestor.put(@base_url + path, options)
    end

    private

    def symbolize_keys(hash)
      Hash[hash.map { |(k, v)| [k.to_sym, v] }]
    end
  end
end
