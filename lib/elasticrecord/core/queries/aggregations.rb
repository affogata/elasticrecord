

module ElasticRecord
  module Queries
    module Aggregations
      def sum(aggregation_name, field)
        self.query.aggregations = {aggregation_name => Elasticsearch::DSL::Search::Aggregations::Sum.new(field: field)}

        return self
      end

      def histogram(aggregation_name, field, interval: 1, **args)
        self.query.aggregations = {
            aggregation_name => Elasticsearch::DSL::Search::Aggregations::Histogram.new({
                                                                                            field: field,
                                                                                            interval: interval,
                                                                                        }.merge(args))
        }

        return self
      end

      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html
      def composite_buckets(aggregation_name, sources, **args)
        self.query.aggregations = {} if self.query.aggregations.nil?

        self.query.aggregations[aggregation_name] = Elasticsearch::DSL::Search::Aggregations::Composite.new({sources: sources}.merge(args))

        return self
      end

      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-datehistogram-aggregation.html
      def date_histogram(aggregation_name, interval_type: 'calendar_interval', interval: '1d',
                         date_field: 'created_at', order: "desc", **args)
        self.query.aggregations = {} if self.query.aggregations.nil?

        self.query.aggregations[aggregation_name] = Elasticsearch::DSL::Search::Aggregations::DateHistogram.new({
                                                                                                                    field: date_field,
                                                                                                                    interval_type => interval,
                                                                                                                    order: order,
                                                                                                                    min_doc_count: 0
                                                                                                                }.merge(args))

        return self
      end
    end
  end
end
