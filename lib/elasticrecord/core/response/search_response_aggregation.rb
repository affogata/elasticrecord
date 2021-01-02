
module ElasticRecord
  class AggregationsResponse < Response
    def aggregations
      @aggs unless @aggs.nil?

      @aggs = @raw[:aggregations].map {|k, v| [k, SearchResponseAggregation.new(k, v)] }.to_h
    end

    def aggregation(key)
      self.aggregations[key]
    end

    def method_missing(method)
      self.aggregation(method)
    end
  end

  class SearchResponseAggregation
    def initialize(aggregation_name, raw)
      @aggregation_name = aggregation_name
      @raw = raw
    end

    def method_missing(method)
      @raw[method]
    end
  end
end
