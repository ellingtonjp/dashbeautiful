module Dashbeautiful
  # description TODO
  module SearchableDashboardObject
    def retrieve(value, api: nil)
      searchable_attributes.each do |attribute|
        obj = find_by(attribute, value, api: api)
        return obj unless obj.nil?
      end
      raise ArgumentError, "Could not find #{self.class}: #{value}"
    end

    def searchable_attributes
      raise NotImplementedError
    end

    def _all(_api: nil)
      raise NotImplementedError
    end

    def all(api:)
      return @all if @all

      if api.nil?
        raise ArgumentError, 'either pass an API or call Dashbeautiful.register' unless Dashbeautiful.registered?

        api = API.new(Dashbeautiful.key)
      end

      @all = _all(api: api)
    end

    def all!(api:)
      @all = nil
      all(api: api)
    end

    def find(api:, &block)
      all(api: api).find(&block)
    end

    def find!(api:, &block)
      all!(api: api).find(&block)
    end

    def find_by(attribute, value, api:)
      find(api: api) { |obj| obj.send(attribute) == value }
    end

    def find_by!(attribute, value, api:)
      find!(api: api) { |obj| obj.send(attribute) == value }
    end
  end
end
