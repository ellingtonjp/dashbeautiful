module Dashbeautiful
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
      @tags = attributes[:tags] || ''

      # TODO: this is currently in Organization, Network, and Device. If you
      #       change in one, you should change in the other. Should probably
      #       figure out how to DRY this out
      instance_variables.each do |var|
        raise ArgumentError, "cannot instantiate with nil value #{var}" if instance_variable_get(var).nil?
      end

      @tags = @tags.split.uniq # same as in Network
    end
  end

  class CameraDevice < Device; end
  class SwitchDevice < Device; end
  class ApplianceDevice < Device; end
  class WirelessDevice < Device; end
  class CombinedDevice < Device; end
end
