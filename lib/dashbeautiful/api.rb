require 'httparty'

# TODO: spec for when api returns no tag attributes
#  perhaps generalize
module Dashbeautiful
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

    def organization(id)
      symbolize_keys(get("/organizations/#{id}"))
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

    def network(id)
      network = symbolize_keys(get("/networks/#{id}"))
      network[:tags] ||= ''
      network
    end

    def networks(organization_id)
      networks = get("/organizations/#{organization_id}/networks").map { |h| symbolize_keys(h) }
      networks.each { |network| network[:tags] ||= '' }
    end

    def update_network(network_id, body)
      valid_keys = %i[name tags]

      raise ArgumentError, 'body must be a hash' unless body.is_a? Hash
      raise ArgumentError, 'body cannot be empty' if body.empty?

      put("/networks/#{network_id}", valid_keys: valid_keys, body: body)
    end

    def update_device(network_id, device_serial, body)
      valid_keys = %i[name tags]

      raise ArgumentError, 'body must be a hash' unless body.is_a? Hash
      raise ArgumentError, 'body cannot be empty' if body.empty?

      put("/networks/#{network_id}/#{device_serial}", valid_keys: valid_keys, body: body)
    end

    def device(network_id, serial)
      device = symbolize_keys(get("/networks/#{network_id}/devices/#{serial}"))
      device[:tags] ||= ''
      device
    end

    def organization_devices(organization_id)
      devices = get("/organizations/#{organization_id}/devices").map { |h| symbolize_keys(h) }
      devices.each { |device| device[:tags] ||= '' }
    end

    def network_devices(network_id)
      devices = get("/networks/#{network_id}/devices").map { |h| symbolize_keys(h) }
      devices.each { |device| device[:tags] ||= '' }
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
