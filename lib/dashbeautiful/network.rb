module Dashbeautiful
  # description TODO
  class Network
    attr_reader :organization, :id, :name, :tags

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
      @tags = attributes[:tags]

      raise ArgumentError if @id.nil? || @name.nil? || @tags.nil?

      @tags = @tags.split.uniq
    end

    def devices
      @devices ||= organization.api.devices(id).map { |device| Device.create(self, **device) }
    end

    def devices!
      @devices = nil
      devices
    end
  end

  class CameraNetwork < Network; end
  class SwitchNetwork < Network; end
  class ApplianceNetwork < Network; end
  class WirelessNetwork < Network; end
  class CombinedNetwork < Network; end
end
