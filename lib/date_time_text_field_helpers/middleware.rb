module DateTimeTextFieldHelpers
  class Middleware
    def initialize(app, year_split=50)
      @app = app
      @year_split = year_split
    end
  
    def call(env)
      request = Rack::Request.new env
      normalize request.params
      @app.call(env)
    end

    private

    def normalize(hsh)
      hsh.each do |key, value|
        hsh[key] = if value.is_a?(Hash)
          normalize value
        elsif key =~ /\([123]i\)$/
          normalize_value key, value
        else
          value
        end
      end
    end

    # Will remove all non-numeric characters.
    # Also converts 2-digit years to 4
    def normalize_value(key, value)
      value = value.gsub /\D+/, ''
      
      value = if value.to_i < @year_split
        "20#{v}"
      else
        "19#{v}"
      end if key =~ /\(1i\)$/ && value =~ /^\d{2}$/

      value
    end
  end
end
