require "bundler/setup"
require "pry-byebug"
require "keepit"

require "mock_redis"

Keepit.configure do |config|
  config.redis = ::MockRedis.new
end

require "timecop"

RSpec.configure do |config|
  config.before(:each) do
    ::Keepit.config.redis.flushdb
  end
end
