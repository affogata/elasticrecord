

module ElasticRecord
  module Queries
    module Boolean
      # Returns documents that contain one or more exact terms in a provided field
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-query.html
      # :param terms             <Array>                    array of contents to match (required)
      def bool(body, query_type: :must, term_type: 'term', **args)
        term_type = 'terms' if term_type == 'term' and (body.is_a?(Array) or (body.is_a?(Hash) and body.values[0].is_a?(Array)))

        query = self.nest!(term_type, body)

        if @bool.blank?
          @bool = Search::Queries::Bool.new
          self.query.query = @bool.send(query_type, query, **args)
        else
          @bool.send(query_type, query, **args)
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

      def nest!(term_type, body={})
        body.each_pair do |field, v|
          field = field.to_s

          sub_fields = field.split(".")

          sub_fields.each_with_index do |sub_field, i|
            # the nested field can either be a sub-field (i.e. "driver"), or an
            # attribute under that sub-field (i.e. "driver.vehicle")
            full_sub_field = sub_fields[0..i].join(".")

            # nested_fields are assigned in the Elastic::Record class
            # using the `nested_field :<field_name>` notation
            if self.nested_fields.include?(full_sub_field.to_s)
              return {nested: {path: sub_field, query: {term_type => {field => v}}}}
            end
          end
        end

        return {term_type => body}
      end
    end
  end
end
