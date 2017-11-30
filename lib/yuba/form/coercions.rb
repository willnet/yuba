module Yuba
  class Form
    module Coercions
      class << self
        def coerce(type:, value:)
          case type
          when :int
            value.present? ? value.to_i : nil
          else
            value
          end
        end
      end
    end
  end
end
