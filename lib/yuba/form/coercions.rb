module Yuba
  class Form
    module Coercions
      class << self
        FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set

        def coerce(type:, value:)
          case type
          when :int
            value.present? ? value.to_i : nil
          when :string
            value.to_s
          when :date
            Date.parse(value)
          when :datetime
            Time.zone.parse(value)
          when :boolean
            !FALSE_VALUES.include?(value)
          when :float
            value.to_f
          when :decimal
            BigDecimal.new(value)
          when :array
            value.empty? ? [] : value
          when :hash
            value.empty? ? {} : value
          else
            value
          end
        end
      end
    end
  end
end
