require 'active_support/core_ext/hash'
require 'ipaddress'

module Meraki
  module Dashboard
    # description TODO
    class Organization
      attr_reader :api, :name, :id, :url

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

      def api_key
        api.key
      end

      def networks
        api.networks(id).map { |network| Network.create(self, **network) }
      end
    end

    # description TODO
    class Network
      attr_reader :organization, :id, :name

      def self.create(*args, **kwargs)
        type = case kwargs[:type]
               when 'camera' then CameraNetwork
               when 'switch' then SwitchNetwork
               when 'wireless' then WirelessNetwork
               when 'appliance' then ApplianceNetwork
               when 'combined' then CombinedNetwork
               else Network
               end
        type.new(*args, **kwargs)
      end

      def self.all(organization)
        raise ArgumentError, 'must pass an Organization' if organization.nil?

        organization.networks
      end

      def self.find(organization, &block)
        all(organization).find(&block)
      end

      def self.find_by_id(id, organization)
        find(organization) { |network| network.id == id }
      end

      def self.find_by_name(name, organization)
        find(organization) { |network| network.name == name }
      end

      def initialize(organization, **attributes)
        @organization = organization
        @id = attributes[:id]
        @name = attributes[:name]
      end

      def devices
        organization.api.devices(id).map { |device| Device.create(self, **device) }
      end
    end

    class CameraNetwork < Network; end
    class SwitchNetwork < Network; end
    class ApplianceNetwork < Network; end
    class WirelessNetwork < Network; end
    class CombinedNetwork < Network; end

    # description TODO
    class Device
      attr_reader :network, :name, :serial, :mac, :model, :tags

      def self.create(*args, **kwargs)
        type = case kwargs[:model]
               when /MV/ then CameraDevice
               when /MS/ then SwitchDevice
               when /MR/ then WirelessDevice
               when /MX/ then ApplianceDevice
               else Device
               end
        type.new(*args, **kwargs)
      end

      def self.all(network)
        raise ArgumentError, 'must pass a Network' if network.nil?

        network.devices
      end

      def initialize(network, **attributes)
        @network = network
        @name = attributes[:name]
        @serial = attributes[:serial]
        @mac = attributes[:mac]
        @model = attributes[:model]
        @tags = attributes[:tags]
      end
    end

    class CameraDevice < Device; end
    class SwitchDevice < Device; end
    class ApplianceDevice < Device; end
    class WirelessDevice < Device; end
    class CombinedDevice < Device; end
  end
end
