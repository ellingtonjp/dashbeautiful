module Dashbeautiful
  # description TODO
  class Network < DashboardBase
    attr_reader :organization

    dash_attr_reader :id, :type
    dash_attr_accessor :name, :tags

    def self.create(**kwargs)
      type = case kwargs[:type]
             when 'camera' then CameraNetwork
             when 'switch' then SwitchNetwork
             when 'wireless' then WirelessNetwork
             when 'appliance' then ApplianceNetwork
             when 'combined' then CombinedNetwork
             else Network
             end
      type.new(**kwargs)
    end

    def self._all(api:)
      Organization.all(api: api).map(&:networks).flatten
    end

    def initialize(organization:, **attrs)
      raise ArgumentError if organization.nil?

      @organization = organization
      super(**attrs)
      @tags = @tags.split.uniq
    end

    def devices
      @devices ||= organization.api.devices(id).map { |device| Device.create(network: self, **device) }
    end

    def devices!
      @devices = nil
      devices
    end

    def attributes_load
      api.network(id)
    end

    def attributes_update(**kwargs)
      api.update_network(id, **kwargs)
    end
  end

  class CameraNetwork < Network; end
  class SwitchNetwork < Network; end
  class ApplianceNetwork < Network; end
  class WirelessNetwork < Network; end
  class CombinedNetwork < Network; end
end
