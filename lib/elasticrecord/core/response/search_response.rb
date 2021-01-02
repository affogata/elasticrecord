
module ElasticRecord
  class SearchResponse < Response
    include Enumerable

    def items
      return @items unless @items.nil?

      @items = hits[:hits].map {|item| SearchResponseHit.new(item, klass: self.klass) }
    end

    def each(&block)
      items.each(&block) if items
    end

    def <=>(other)
      items.size <=> other.items.size
    end

    def [](v)
      self.items[v]
    end

    def length
      self.items.length
    end

    def blank?
      Array.wrap(self.items).length == 0
    end

    def suggestions
      @suggestions unless @suggestions.nil?

      @aggs = @raw[:suggest].map {|k, v| SearchResponseSuggestions.new(k, v) }
    end
  end
end