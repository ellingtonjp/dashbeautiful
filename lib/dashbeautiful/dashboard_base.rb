module Dashbeautiful
  # description TODO
  class DashboardBase
    @@dash_readers = {}
    @@dash_writers = {}
    @@dash_accessors = {}

    def self.dash_attr_reader(*vars)
      @@dash_readers[self] ||= []
      @@dash_readers[self].concat vars
    end

    def self.dash_attr_writer(*vars)
      @@dash_writers[self] ||= []
      @@dash_writers[self].concat vars
    end

    def self.dash_attr_accessor(*vars)
      @@dash_accessors[self] ||= []
      @@dash_accessors[self].concat vars
    end

    def self.get_attributes(attrs)
      attributes = []
      curr = self
      while curr < DashboardBase
        attrs[curr] ||= []
        attributes.concat attrs[curr]
        curr = curr.superclass
      end
      attributes
    end

    def self.dash_readers
      get_attributes(@@dash_readers)
    end

    def self.dash_writers
      get_attributes(@@dash_writers)
    end

    def self.dash_accessors
      get_attributes(@@dash_accessors)
    end

    def self.dash_attributes
      dash_accessors + dash_writers + dash_readers
    end

    def define_dash_reader(attr)
      define_singleton_method attr do
        instance_variable_get("@#{attr}".to_sym)
      end

      define_singleton_method "#{attr}!" do
        instance_variable_set("@#{attr}".to_sym, attributes_load[attr])
        send(attr)
      end
    end

    def define_dash_writer(attr)
      define_singleton_method "#{attr}=".to_sym do |value|
        instance_variable_set("@#{attr}".to_sym, value)
      end

      define_singleton_method "update_#{attr}".to_sym do |value|
        body = {}
        body[attr] = value
        attributes_update(**body)
        instance_variable_set("@#{attr}".to_sym, value)
      end
    end

    def define_dash_accessor(attr)
      define_dash_reader(attr)
      define_dash_writer(attr)
    end

    def validate_attributes(**attrs)
      # TODO: figure out how to handle attributes returned from API that aren't defined by eg dash_attr_reader
      # attr_keys = attrs.keys
      # raise ArgumentError, "passed attributes #{attr_keys} not in #{self.class.dash_attributes}" unless self.class.dash_attributes.sort == attr_keys.sort

      self.class.dash_attributes.each do |attr|
        raise ArgumentError, "cannot instantiate with nil value #{attr}" if attrs[attr].nil?
      end
    end

    def self._all(_api: nil)
      raise NotImplementedError
    end

    def self.all(api: nil)
      return @all if @all

      if api.nil?
        raise ArgumentError, 'either pass an API or call Dashbeautiful.register' unless Dashbeautiful.registered?

        api = API.new(Dashbeautiful.key)
      end

      @all = _all(api: api)
    end

    def self.all!(api: nil)
      @all = nil
      all(api: api)
    end

    def self.find(api:, &block)
      all(api: api).find(&block)
    end

    def self.find!(api:, &block)
      all!(api: api).find(&block)
    end

    def self.find_by(attribute, value, api:)
      find(api: api) { |obj| obj.send(attribute) == value }
    end

    def self.find_by!(attribute, value, api:)
      find!(api: api) { |obj| obj.send(attribute) == value }
    end

    # TODO: should we have init! ? Does it make sense to
    # skip caching for this method?
    def self.init(value, api: nil)
      dash_attributes.each do |attribute|
        obj = find_by(attribute, value, api: api)
        return obj unless obj.nil?
      end
      raise ArgumentError, "Could not find #{self.class}: #{value}"
    end

    def initialize(**attrs)
      validate_attributes(attrs)
      self.class.dash_attributes.each { |attr| instance_variable_set("@#{attr}".to_sym, attrs[attr]) }
      self.class.dash_readers.each { |attr| define_dash_reader(attr) }
      self.class.dash_writers.each { |attr| define_dash_writer(attr) }
      self.class.dash_accessors.each { |attr| define_dash_accessor(attr) }
    end

    def update(**kwargs)
      attributes_update(**kwargs)
    end

    def reload
      info = attributes_load
      self.class.dash_attributes.each do |attr|
        instance_variable_set("@#{attr}", info[attr])
      end
    end

    def save
      attrs = self.class.dash_accessors + self.class.dash_writers
      body = {}
      attrs.each { |attr| body[attr] = send(attr) }
      attributes_update(**body)
    end

    def attributes_load
      raise NotImplementedError
    end

    def attributes_update
      raise NotImplementedError
    end
  end
end
