module Dashbeautiful
  # description TODO
  class Organization < DashboardBase
    attr_accessor :api

    dash_attr_reader :id, :url
    dash_attr_accessor :name

    extend Dashbeautiful::SearchableDashboardObject

    def self._all(api:)
      api.organizations.map { |org| Organization.new(api: api, **org) }
    end

    def initialize(api:, **attrs)
      raise ArgumentError if api.nil?

      @api = api
      super(**attrs)
    end

    def networks
      @networks ||= api.networks(id).map { |network| Network.create(organization: self, **network) }
    end

    def networks!
      @networks = nil
      networks
    end

    def find_network(attribute, value)
      networks.find do |network|
        network.send(attribute) == value
      end
    end

    def find_network!(attribute, value)
      networks!.find do |network|
        network.send(attribute) == value
      end
    end

    def network(value)
      Network.attributes.each do |attribute|
        find_network(attribute, value)
      end
    end

    def network!(value)
      Network.attributes.each do |attribute|
        find_network!(attribute, value)
      end
    end

    def attributes_load
      api.organization(id)
    end

    def attributes_update(**kwargs)
      api.update_organization(id, **kwargs)
    end
  end
end
