

module ElasticRecord
  module Query
    module ClassMethods
      def _search(index: nil, type: nil, **args)
        ElasticRecord::Search.new(self,
                                  types: type || self.default_type,
                                  index: index || self.default_index,
                                  nested_fields: self.nested_fields,
                                  default_field: self.default_field,
        )
      end

      def where(search, **args)
        self._search(**args).where(search, **{match_type: :filter}.merge(args))
      end

      def filter(search, **args)
        self._search(**args).filter(search, **args)
      end

      def must_include(search, **args)
        self._search(**args).must_include(search, **args)
      end

      def must_not_include(search, **args)
        self._search(**args).must_not_include(search, **args)
      end

      alias_method :exclude, :must_not_include

      def should_include(search, **args)
        self._search(**args).should_include(search, **args)
      end

      def bool_query(search, **args)
        self._search(**args).bool_query(search, **args)
      end

      def in_range(search, match_type: :filter, term_type: :range, **args)
        self._search(**args).in_range(search, match_type: match_type, term_type: term_type, **args)
      end

      def exists(field)
        self.where({field: field}, term_type: :exists)
      end

      def self.by_ids(ids, **args)
        self.where(Array.wrap(ids), match_type: :by_ids, **args).limit(Array.wrap(ids).length)
      end

      def self.find_by_id(id, **args)
        docs = self.by_ids(id, **args).all

        return docs.items.first unless docs.items.to_a.length == 0
      end

      def self.use_index(index_name, **args)
        self._search(**args).use_index(index_name)
      end

      def update(**args)
        ElasticRecord::Client.new.update(**args)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end