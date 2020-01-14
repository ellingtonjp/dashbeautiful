module Meraki
  module Dashboard
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
