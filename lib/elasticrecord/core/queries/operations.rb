

module ElasticRecord
  module Queries
    module Operations
      attr_accessor :klass, :index, :types, :default_field
      attr_accessor :_limit, :_offset, :_source

      def add_filter(k, v)
        self.filters[k] = v

        return self
      end

      def filters
        @filters ||= {}
      end

      def sort(sort_by, direction=nil)
        #self.query.sort(sort_by, direction)
        self.query.sort = Search::Sort.new if self.query.sort.nil?

        if sort_by.is_a?(String)
          self.query.sort.by(sort_by, direction)
        elsif sort_by.is_a?(Hash)
          sort_by.each_pair {|k, v| self.query.sort.by(k, v)}
        elsif sort_by.is_a?(Array)
          sort_by.each {|item| item.is_a?(Hash) ? self.query.sort.by(item.keys[0], item.values[0]) : self.query.sort.by(item)}
        end

        return self
      end

      def use_index(index_name)
        return self if index_name.blank?

        index = Array.wrap(index_name).join(",")

        self.index = index
        self.add_filter(:index, index)

        return self
      end

      def limit(v)
        self._limit = v.to_i unless v.nil?
        return self
      end

      def offset(v)
        self._offset = v.to_i unless v.nil?
        return self
      end

      def select(v)
        v = v.split(",").map(&:strip) if v.is_a?(String)

        self._source = v

        return self
      end

      alias_method :skip, :offset
      alias_method :order, :sort
    end
  end
end