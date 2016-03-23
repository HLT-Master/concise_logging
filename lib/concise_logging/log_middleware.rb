module ConciseLogging
  class LogMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      Thread.current[:logged_ip] = request.env['HTTP_X_REAL_IP'] || request.ip
      Thread.current[:logged_headers] = request_headers(request)
      @app.call(env)
    ensure
      Thread.current[:logged_ip] = nil
      Thread.current[:logged_headers] = nil
    end

    def request_headers(request)
      header_keys = ['HTTP_PLATFORM',
                 'HTTP_X_HLTBUNDLEIDENTIFIER',
                 'HTTP_X_USER_TOKEN',
                 'HTTP_X_USER_EMAIL',
                 'HTTP_APP_VERSION',
                 'HTTP_VERSION',
                 'HTTP_DEVICE_IDENTIFIER',
                 'HTTP_HLTLASTUPDATEDAT']
      h = request.headers.select{|header_name, header_value| header_keys.index(header_name)}
      Hash[*h.flatten]
    end
  end
end
