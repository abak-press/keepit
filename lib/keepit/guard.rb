# Базовый класс защитника от ошибок при обращении к сторонним сервисам.
#
# Основной принцип работы:
#
#   Каждый сервис-клиент реализует свой класс защитника со списком возможных исключений.
#   Если сторонний сервис возвращает определнное кол-во ошибок, которое больше некого порога,
#   то защитник перестает давать общаться с ним на некоторое время.
#   До преодоления порога мы сообщаем об ошибках в NewRelic и письмом проектому менеджеру.
#   Также защитник не дает общаться с сервисом, если он находится на тех. обслуживании.
#
# Examples:
#
#   Keepit::Guard.config.error_notificator = ->(resource, error) { ErrorMailer.report(resource, error) }
#
#   module BarmenClient
#     class Guard < ::Keepit::Guard
#       config.resource = "barmen".freeze
#       config.rescue_errors = [ActiveResource::ConnectionError]
#     end
#   end
#
#   BarmenClient::Guard.wrap { BarmenClient::Banner.find(...) }
#
module Keepit
  class Guard
    extend Dry::Configurable

    setting :resource, reader: true
    setting :rescue_errors, [StandardError], reader: true
    setting :max_error_rate, 10, reader: true
    setting :error_notificator, reader: true

    class << self
      def wrap
        return nil unless fine?
        yield
      rescue *rescue_errors => error
        error_rates[resource] << 1
        error_notificator.call(resource, error)
        nil
      end

      def reset
        error_rates.clear
      end

      def fine?
        !error_rate_exceeded? && !resource_locked?
      end

      private

      def error_rates
        @error_rates ||= Hash.new { |hash, key| hash[key] = ::Keepit::Decaying.new }
      end

      def error_rate_exceeded?
        error_rates[resource].value >= (max_error_rate || DEFAULT_MAX_ERROR_RATE)
      end

      def resource_locked?
        ::Keepit::Locker.locked?(resource, check_global: false)
      end
    end
  end
end
