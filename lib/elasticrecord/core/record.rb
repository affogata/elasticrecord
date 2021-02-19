require 'ostruct'

module ElasticRecord
  class Record
    include ElasticRecord::Query

    attr_accessor :attrs

    def initialize(**attrs)
      self.attrs = OpenStruct.new(attrs)
    end

    def _model
      @model = self.attrs
    end

    def method_missing(method)
      self._model.try(method)
    end

    def self.default_type
      # INTERFACE
    end

    def self.default_field
      # INTERFACE
    end

    def self.default_index
      # INTERFACE
    end

    def self.nested_fields
      @@nested_fields ||= Set.new
    end

    def nested_fields
      self.class.nested_fields
    end

    def self.nested_field(field_name)
      nested_fields.add(field_name.to_s)
    end
  end
end