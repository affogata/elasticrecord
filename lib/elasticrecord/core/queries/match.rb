
module ElasticRecord
  module Queries
    module Match
      # Match a search query
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html
      # :param args          <Hash>                    content of query (required)
      def match(body, **args)
        self.query.query = Search::Queries::Match.new(body)

        return self
      end

      # Match all search query
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-ids-query.html
      # :param body          <Hash>                    content of query (required)
      def by_ids(ids, **args)
        self.query.query = Search::Queries::Ids.new(values: ids)

        return self
      end

      # Match all search query
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-all-query.html
      # :param body          <Hash>                    content of query (required)
      def match_all(body, **args)
        self.query.query = Search::Queries::MatchAll.new(body)

        return self
      end

      # Returns documents matching boolean combinations of other queries
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html
      # :param terms             <Array>                    array of contents to match (required)
      def terms(key, terms, **args)
        self.query.query += Search::Queries::Terms.new({key => terms}, **args)

        return self
      end

      def match_phrase(body, **args)
        self.query.query = Search::Queries::MultiMatch.new(body)

        return self
      end
    end
  end
end
