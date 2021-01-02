

module ElasticRecord
  class Response
    attr_accessor :klass
    attr_accessor :body

    def initialize(raw, klass: nil, body: nil, **args)
      self.klass = klass
      self.body = body

      @raw = raw.deep_symbolize_keys!
    end

    def success
      @raw[:timed_out] == false
    end

    def hits
      @raw[:hits]
    end

    def total
      hits[:total]
    end

    def max_score
      hits[:max_score]
    end
  end
end
