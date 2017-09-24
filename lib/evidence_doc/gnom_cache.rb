module EvidenceDoc
  class GnomeCache
    def initialize
      @_index_cache = {}
    end

    def contains?(key)
      @_index_cache.has_key?(key)
    end

    def put(key, value)
      @_index_cache[key] = value
    end

    def delete key
      @_index_cache.delete key
    end

    def [](key)
      @_index_cache[key]
    end

    def clear!
      @_index_cache.clear
    end

    def size
      @_index_cache.size
    end

    def to_hash
      @_index_cache
    end
  end
end
