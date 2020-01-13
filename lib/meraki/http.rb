require 'httparty'

module Meraki
  # description TODO
  class HTTP # TODO: rename to API
    attr_reader :api_key

    def initialize(api_key, requestor: HTTParty)
      @api_key = api_key
      @base_url = 'https://api.meraki.com/api/v0'
      @headers = {
        'X-Cisco-Meraki-API-Key' => key
      }
      @options = {
        headers: @headers
      }
      @requestor = requestor
    end

    def organizations
      get('/organizations').map(&:symbolize_keys)
    end

    def networks(organization_id)
      get("/organizations/#{organization_id}/networks").map(&:symbolize_keys)
    end

    def devices(network_id)
      get("/networks/#{network_id}/devices").map(&:symbolize_keys)
    end

    def get(path, **options)
      @requestor.get(@base_url + path, @options.merge(options))
    end
  end
end
