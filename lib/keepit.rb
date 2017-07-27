require "redis"
require "dry/configurable"
require "keepit/decaying"
require "keepit/transient_store"
require "keepit/locker"
require "keepit/guard"
require "keepit/version"

module Keepit
  extend Dry::Configurable

  setting :redis

  def self.redis
    config.redis || ::Redis.current
  end
end
