# frozen_string_literal: true

# Patch para Ruby 4.0 + json 3.0.2
# ActiveSupport 8.1.3.1 chama ::JSON.parse(json, options) com Hash posicional,
# mas json 3.0.2 mudou para kwargs: def parse(source, on_load: nil, ..., **options)
# Isso causava ArgumentError (given 2, expected 1) -> ParseError 400 em toda requisição JSON.
# Veja: active_support/json/decoding.rb:25 vs json/common.rb:296

module ActiveSupport
  module JSON
    class << self
      def decode(json, options = {})
        data = ::JSON.parse(json, **options)
        if ActiveSupport.parse_json_times
          send(:convert_dates_from, data)
        else
          data
        end
      end
      alias_method :load, :decode
    end
  end
end
