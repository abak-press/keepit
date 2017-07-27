module Keepit
  module Locker
    GLOBAL = "global".freeze
    KEY = "keepit:locks".freeze
    EXPIRES_IN = 60

    def self.lock(resources, blocking = false)
      result = ::Keepit.redis.sadd(KEY, resources)
      sleep(EXPIRES_IN) if blocking

      result
    end

    def self.unlock(resources, blocking = false)
      result = ::Keepit.redis.srem(KEY, resources)
      sleep(EXPIRES_IN) if blocking

      result
    end

    def self.locked?(resource, check_global: true)
      if check_global
        locked_resources.any? { |r| r == resource || r == GLOBAL }
      else
        locked_resources.any? { |r| r == resource }
      end
    end

    def self.locked_resources
      ::Keepit::TransientStore.fetch(:locks, expires_in: EXPIRES_IN) do
        Array(::Keepit.redis.smembers(KEY))
      end
    end
  end
end
