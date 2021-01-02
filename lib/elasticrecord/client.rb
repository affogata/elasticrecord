require 'elasticsearch/dsl'

module ElasticRecord
  module Searchable
    def index(name, body, index_type: nil)
      self.client.index(index: name, type: index_type, body: body)
    end

    def bulk(index: nil, **args)
      Array.wrap(index).map { |idx_name| res << self.client.bulk(index: idx_name, **args) }
    end

    def add_mapping(index_name, field, **body)
      self.client.perform_request('PUT', "#{index_name}/_mapping", {}, {properties: {field => body}})
    end

    def perform_request(method, path, params={}, body=nil, headers=nil)
      self.client.perform_request(method, path, params, body, headers)
    end

    def indices
      self.perform_request('GET', '_aliases').body.keys.reject {|k| k.start_with?('.') }
    end

    def update(**args)
      self.client.update(args)
    end

    def count(query, **args)
      self.client.count(body: query.to_hash, **query.filters.merge(args))['count']
    end

    def _search(body, **args)
      self.client.search(args.merge(body: body.is_a?(Elastic::Search) ? body.to_hash : body))
    end

    def search(body, klass: nil, **args)
      ElasticRecord::SearchResponse.new(self._search(body, **args), klass: klass, body: body)
    end

    def aggregate(body, query: nil, klass: nil, **args)
      query_args = {}

      unless query.nil?
        body = body.merge(query.to_hash)
        query_args = query.filters
      end

      args = {size: 0}.merge(query_args).merge(args)
      args[:index] = query.index unless query.index.nil?

      ElasticRecord::AggregationsResponse.new(self._search(body, args), klass: klass)
    end

    def reindex(old_idx_name, new_idx_name, params: {}, body: {}, source: {}, dest: {})
      self.index(new_idx_name, {}) unless self.indices.include?(new_idx_name)

      self.client.perform_request('POST', '_reindex', {
          wait_for_completion: false,
          slices: 6
      }.merge(params), {
          source: {
              index: old_idx_name
          }.merge(source),
          dest: {
              index: new_idx_name
          }.merge(dest)
      }.merge(body))
    end

    def add_logs(indices, action_type: 'search', log_type: 'slowlog', **logs)
      indices.each do |index|
        logs.each_pair do |log_level, min_query_time|
          self.perform_request('PUT', "#{index}/_settings", {}, {"index.#{action_type}.#{log_type}.threshold.query.#{log_level}" => min_query_time})
        end
      end
    end
  end
end
