module Dashbeautiful
  # description TODO
  class Organization
    attr_accessor :api
    attr_reader :name, :id, :url

    ATTRIBUTES = %i[id name url].freeze

    def self.all(api_key, api: API.new(api_key))
      raise ArgumentError, 'api_key is nil. Either initialize Organization or pass a key' if api_key.nil?

      api.organizations.map { |org| Organization.new(api, **org) }
    end

    def self.find_by(attribute, value, api_key, api: API.new(api_key))
      all(api_key, api: api).each do |org|
        return org if org.send(attribute) == value
      end
      nil
    end

    def self.init(organization:, api_key:, api: API.new(api_key))
      ATTRIBUTES.each do |attribute|
        org = find_by(attribute, organization, api_key, api: api)
        return org unless org.nil?
      end
      raise ArgumentError, "Could not find organization: #{organization}"
    end

    def initialize(api, **attributes)
      @api = api
      @id = attributes[:id]
      @name = attributes[:name]
      @url = attributes[:url]
    end

    def name=(value)
      api.update_organization(id, name: value)
      @name = value
    end

    def api_key
      api.key
    end

    def networks
      @networks ||= api.networks(id).map { |network| Network.create(self, **network) }
    end

    def networks!
      @networks = nil
      networks
    end
  end
end
