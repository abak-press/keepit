module Keepit
  module TransientStore
    Value = Struct.new(:value, :expired_at) do
      def expired?
        expired_at < Time.now.to_i
      end
    end

    def self.clear
      store.clear
    end

    def self.delete(key)
      item = store.delete(key)
      item.value if item
    end

    def self.empty?
      store.empty?
    end

    def self.exist?(key)
      return true if store.key?(key) && !store[key].expired?

      delete(key)

      false
    end

    def self.fetch(key, expires_in:, &block)
      if exist?(key)
        store[key].value
      else
        value = yield
        write(key, value, expires_in: expires_in)
      end
    end

    def self.read(key)
      store[key].value if exist?(key)
    end

    def self.store
      Thread.current[:keepit_transient_store] ||= {}
    end

    def self.write(key, value, expires_in:)
      store[key] = Value.new(value, Time.now.to_i + expires_in.to_i)

      value
    end
  end
end
