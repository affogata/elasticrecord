

module ElasticRecord
  module Queries
    module Boolean
      # Returns documents that contain one or more exact terms in a provided field
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-query.html
      # :param terms             <Array>                    array of contents to match (required)
      def bool(body, query_type: :must, term_type: 'term', **args)
        term_type = 'terms' if term_type == 'term' and (body.is_a?(Array) or (body.is_a?(Hash) and body.values[0].is_a?(Array)))

        if @bool.nil?
          @bool = Search::Queries::Bool.new
          self.query.query = @bool.send(query_type, {term_type => body}, **args)
        else
          @bool.send(query_type, {term_type => body}, **args)
        end

        return self
      end

      def must_include(body, **args)
        self.bool(body, **args)
      end

      def must_not_include(body, **args)
        self.bool(body, query_type: :must_not, **args)
      end

      alias_method :exclude, :must_not_include

      def filter(body, **args)
        self.bool(body, query_type: :filter, **args)
      end

      def should_include(body, **args)
        self.bool(body, query_type: :should, **args)

        @bool.minimum_should_match(args[:minimum_should_match]) if args[:minimum_should_match].to_i > 0

        return self
      end

      def bool_query(body, **args)
        self.bool(body, **{query_type: :must, term_type: :query_string}.merge(args))
      end

      def in_range(body, **args)
        self.bool(body, **{query_type: :filter, term_type: :range}.merge(args))
      end

      def exists(body, **args)
        self.bool({field: body}, term_type: :exists, **args)
      end
    end
  end
end
