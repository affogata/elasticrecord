
module ElasticRecord
  class SearchResponseHit
    attr_accessor :klass

    def initialize(raw, klass: nil)
      self.klass = klass
      @raw = raw
    end

    def index
      @raw[:_index]
    end

    def type
      @raw[:_type]
    end

    def id
      @raw[:_id]
    end

    def score
      @raw[:_score]
    end

    def highlight
      @raw[:highlight]
    end

    def attributes
      return @attributes unless @attributes.nil?

      @attributes = self.klass.nil? ? @raw[:_source] : self.klass.new(@raw[:_source])

      return @attributes
    end

    def extract_attr(field, attrs=nil)
      attrs = self.attrs if attrs.nil?
      field = field.to_s

      if field.include?('.')
        split_field = field.split('.')

        if attrs[split_field[0].to_sym].is_a?(Array)
          res = []

          (0...attrs[split_field[0].to_sym].length).to_a.each do |i|
            res << self.extract_attr(split_field[1..-1].join("."), attrs[split_field[0].to_sym][i])
          end

          return res.join(",")
        else
          return self.extract_attr(split_field[1..-1].join("."), attrs[split_field[0].to_sym])
        end
      end

      return attrs.nil? ? nil : attrs[field.to_sym]
    end

    def method_missing(method)
      self.attributes.send(method)
    end
  end
end
