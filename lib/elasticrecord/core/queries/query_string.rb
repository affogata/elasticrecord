
module ElasticRecord
  module Queries
    module QueryString
      # Match boolean query string
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
      # :param body             <String>                    content of query (required)
      # :param default_operator <String>                    use AND/OR as operator when not specified (default: 'AND')
      # :param args
      #           default_field <String>                    default field to perform query on
      def query(query, default_operator: 'AND', **args)
        self.query.query = Search::Queries::QueryString.new({
            query: query,
            default_operator: default_operator
        }.merge(args))

        return self
      end
    end
  end
end
