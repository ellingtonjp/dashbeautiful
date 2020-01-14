require 'httparty'
require 'active_support/core_ext/hash'

module Meraki
  # description TODO
  class API
    attr_reader :key

    def initialize(key, requestor: HTTParty)
      @key = key
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
