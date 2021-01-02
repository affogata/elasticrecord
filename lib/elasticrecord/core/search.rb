require 'json'

module ElasticRecord
  class Search
    include Elasticsearch::DSL

    include Queries::Match
    include Queries::QueryString
    include Queries::Boolean
    include Queries::Aggregations
    include Queries::Suggestions
    include Queries::Operations

    def initialize(klass, index: nil, types: nil, default_field: nil)
      self.klass = klass
      self.index = index
      self.types = types

      self.default_field = default_field
    end

    def query
      @query ||= Search::Search.new
    end

    def where(search, match_type: :must_include, **args)
      args[:type] = self.types unless self.types.nil?

      self.send(match_type, search, **args)

      return self
    end

    def self.exists(field)
      self.where({field: field}, term_type: :exists)
    end

    def in_range(search, **args)
      self.where(search, **{match_type: :filter, term_type: :range}.merge(args))
    end

    def all(**args)
      # originally we'd let the search go through all indices when no index
      # was supplied, but sometimes we'd wish to create test or temporary
      # indices and we don't want them to potentially interfere
      args[:index] = self.index unless self.index.nil?

      args[:klass] = self.klass unless self.klass.nil?
      args[:size] = self._limit unless self._limit.nil?
      args[:from] = self._offset unless self._offset.nil?
      args[:_source] = self._source unless self._source.nil?

      # limit results to docs of the relevant types. so, for example, on a +Elastic::Status+
      # the default type is 'status', which further narrows the query to this doc type
      self.filter(type: self.types) unless self.types.nil?

      ElasticRecord::Client.new.search(self, **args)
    end

    def each(&block)
      self.all.each(&block)
    end

    def map(&block)
      self.all.map(&block)
    end

    def index_by(&block)
      self.all.index_by(&block)
    end

    def length
      self.all.length
    end

    def count(**args)
      args[:index] = self.index unless self.index.nil?

      ElasticRecord::Client.new.count(self, args)
    end

    def highlight!(args=nil)
      return if args.nil?

      self.query.highlight(args)

      return self
    end

    def to_query
      self.query.to_hash
    end

    def to_hash
      JSON.parse(self.to_query.to_json, symbolize_names: true)
    end

    def duplicate
      new_query = self.class.new(self.klass, index: self.index, types: self.types)

      bool = Elastic::Search::Queries::Bool.new
      new_hash = {}.ko_deep_merge!(@bool.instance_variable_get(:@hash))
      bool.instance_variable_set(:@hash, new_hash)

      new_query.instance_variable_set(:@bool, bool)
      new_query.query.query = bool

      if self.query.highlight
        new_query.highlight!(self.query.highlight.to_hash)
      end

      return new_query
    end
  end
end