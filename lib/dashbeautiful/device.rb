module Dashbeautiful
  # description TODO
  class Device < DashboardBase
    attr_reader :network

    dash_attr_reader :serial, :mac, :model
    dash_attr_accessor :name, :tags

    def self.create(**kwargs)
      type = case kwargs[:model]
             when /MV/ then CameraDevice
             when /MS/ then SwitchDevice
             when /MR/ then WirelessDevice
             when /MX/ then ApplianceDevice
             else Device
             end
      type.new(**kwargs)
    end

    def initialize(network:, **attrs)
      raise ArgumentError if network.nil?

      @network = network
      super(**attrs)
    end

    def self._all(api:)
      Organization.all(api).map(&:networks).map(&:devices).flatten
    end

    def attributes_load
      api.device(network.id, serial)
    end

    def attributes_update(**kwargs)
      api.update_device(network.id, serial, **kwargs)
    end
  end

  class CameraDevice < Device; end
  class SwitchDevice < Device; end
  class ApplianceDevice < Device; end
  class WirelessDevice < Device; end
  class CombinedDevice < Device; end
end
