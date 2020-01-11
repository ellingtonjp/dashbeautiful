require 'active_support/core_ext/hash'
require 'ipaddress'

module Meraki
  module Dashboard
    class Organization
      attr_reader :http, :name, :id

      ATTRIBUTES = [:name, :id]

      @@api_key = nil

      def self.all(api_key = @@api_key, http: HTTP.new(api_key))
        raise ArgumentError, "api_key is nil. Either initialize Organization or pass a key" if api_key.nil?
        @@http = http
        @@http.organizations.map { |org| Organization.new(@@http, **org) }
      end

      def self.api_key
        @@http.api_key
      end

      def self.init(organization:, api_key: @@api_key, http: HTTP.new(api_key))
        @@http = http
        @@api_key = api_key
        Network.init(self)

        @@organization = nil
        all(api_key).each do |org|
          ATTRIBUTES.each do |org_attribute|
            return @@organization = org if org.send(org_attribute) == organization
          end
        end
        raise ArgumentError, "Could not find organization: #{organization}"
      end

      def all(api_key = @api_key)
        Organization.all(api_key)
      end

      def self.organization
        @@organization
      end

      def self.http
        @@http
      end

      def self.find(&block)
        all.find(&block)
      end

      def self.find_by_name(name)
        find { |org| org.name == name }
      end

      def self.find_by_id(name)
        find { |org| org.id == id }
      end

      def initialize(http, **attributes)
        @http = http
        @api_key = @http.api_key
        @id = attributes[:id]
        @name = attributes[:name]
      end

      def api_key
        @http.api_key
      end

      def networks
        @http.networks(id).map { |network| NetworkFactory.create(@http, self, **network) }
      end
    end

    class NetworkFactory
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
    end

    class Network
      attr_reader :organization, :id, :name

      def self.init(organization)
        @@organization = organization
        @@http = @@organization.http
      end

      def self.all
        org = @@organization
        raise "organization not registered with client" unless org
        org.networks
      end

      def self.find(&block)
        all.find(&block)
      end

      def self.find_by_id(id)
        find { |network| network.id == id }
      end

      def self.find_by_name(name)
        find { |network| network.name == name }
      end

      def initialize(http, organization, **attributes)
        @http = http
        @organization = organization
        @id = attributes[:id]
        @name = attributes[:name]
      end

      def devices
        @http.devices(id).map { |device| DeviceFactory.create(@http, self, device) }
      end
    end

    class CameraNetwork < Network; end
    class SwitchNetwork < Network; end
    class ApplianceNetwork < Network; end
    class WirelessNetwork < Network; end
    class CombinedNetwork < Network; end

    class DeviceFactory
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
    end


    class Device
      attr_reader :organization, :network, :id, :name, :serial, :mac, :model, :tags, :firmware, :lanip, :mtunnel

      def initialize(http, network, **attributes)
        @http = http
        @organization = organization
        @network = network
        @id = attributes[:id]
        @name = attributes[:name]
        @serial = attributes[:serial]
        @mac = attributes[:mac]
        @model = attributes[:model]
        @tags = attributes[:tags]
        @tags = attributes[:firmware]
        @lanip = attributes[:lanip]
        @mtunnel = Dashboard.mtunnel(@mac)
      end
    end

    class CameraDevice < Device; end
    class SwitchDevice < Device; end
    class ApplianceDevice < Device; end
    class WirelessDevice < Device; end
    class CombinedDevice < Device; end

    def self.mtunnel(device_mac)
      mac = 0
      # NOTE: do not do this by "removing ':' then parse as hex", as we dont know if mac addresses will always have leading zeros.
      device_mac.split(':').reverse.each_with_index do |val, i|
        # parse byte as hex. Shift ix8 bits, and add up
        mac += val.to_i(16) << (i * 8)
      end
      prefix = 0xFD0A9B0901F70000 << 64

      bytes = prefix
      bytes |= ((mac & 0xFDFFFF000000) ^ (2 << 40)) << 16
      bytes |= 0xFFFE000000
      bytes |= mac & 0xFFFFFF

      # convert to string
      ipv6 = bytes.to_s(16)
      # carve up and add : for proper ipv6 formating
      ipv6 = "#{ipv6[0..3]}:#{ipv6[4..7]}:#{ipv6[8..11]}:#{ipv6[12..15]}:#{ipv6[16..19]}:#{ipv6[20..23]}:#{ipv6[24..27]}:#{ipv6[28..31]}"
      ipv6 = IPAddress::IPv6.new(ipv6)
      return ipv6.compressed
    end
  end
end
