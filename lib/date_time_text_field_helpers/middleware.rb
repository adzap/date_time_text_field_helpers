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
        elsif key =~ /\(1i\)$/ && value =~ /^\d{2}$/
          if value.to_i < @year_split
            "20#{value}"
          else
            "19#{value}"
          end
        else
          value
        end
      end
    end
  end
end
