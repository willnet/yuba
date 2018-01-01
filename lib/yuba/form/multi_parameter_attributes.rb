class Yuba::Form::MultiParameterAttributes
  def self.call(params)
    new.call(params)
  end

  def call(params)
    params = params.dup
    date_attributes = {}
    params.each do |attribute, value|
      if value.is_a?(Hash)
        params[attribute] = call(value)
      elsif matches = attribute.match(/^(\w+)\(.i\)$/)
        date_attribute = matches[1]
        date_attributes[date_attribute] = params_to_date(
          params.delete("#{date_attribute}(1i)"),
          params.delete("#{date_attribute}(2i)"),
          params.delete("#{date_attribute}(3i)"),
          params.delete("#{date_attribute}(4i)"),
          params.delete("#{date_attribute}(5i)")
        )
      end
    end
    date_attributes.each do |attribute, date|
      params[attribute] = date
    end
    params
  end

  private

  def params_to_date(year, month, day, hour, minute)
    date_fields = [year, month, day].map!(&:to_i)
    time_fields = [hour, minute].map!(&:to_i)
    if date_fields.any?(&:zero?) || !Date.valid_date?(*date_fields)
      return nil
    end
    if hour.blank? && minute.blank?
      Date.new(*date_fields)
    else
      args = date_fields + time_fields
      Time.zone.local(*args)
    end
  end
end
