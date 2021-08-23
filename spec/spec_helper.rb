require "bundler/setup"
require "pry-byebug"
require "keepit"

Keepit.configure do |config|
  config.redis = Redis.new(host: ENV['TEST_REDIS_HOST'])
end

require "timecop"

RSpec.configure do |config|
  config.before(:each) do
    ::Keepit.config.redis.flushdb
  end
end
