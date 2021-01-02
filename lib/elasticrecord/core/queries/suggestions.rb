
module ElasticRecord
  module Queries
    module Suggestions
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-suggesters.html
      def suggest(suggestion_name, body, **args)
        self.query.suggest = {suggestion_name => Elasticsearch::DSL::Search::Suggest.new(suggestion_name, args.merge(body))}

        return self
      end
    end
  end
end