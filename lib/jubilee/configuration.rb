module Jubilee
  class Configuration
    attr_reader :app

    def initialize(options, &block)
      @options = options
      @block = block
    end

    def app
      @app ||= load_rack_adapter(@options, &@block)
      if !@options[:quiet] and @options[:environment] == "development"
        logger = @options[:logger] || STDOUT
        Rack::CommonLogger.new(@app, logger)
      else
        @app
      end
    end

    def port
      @options[:Port]
    end

    def host
      @options[:Host]
    end

    def ssl
      @options[:ssl]
    end
    
    def keystore_path
      @options[:keystore_path]
    end

    def keystore_password
      @options[:keystore_password]
    end

    private
    def load_rack_adapter(options, &block)
      if block
        inner_app = Rack::Builder.new(&block).to_app
      else
        if options[:rackup]
          Kernel.load(options[:rackup])
          inner_app = Object.const_get(File.basename(options[:rackup], '.rb').capitalize.to_sym).new
        else
          Dir.chdir options[:chdir] if options[:chdir]
          inner_app, opts = Rack::Builder.parse_file "config.ru"
        end
      end
      inner_app
      #Rack::Builder.new do
      #  use Rack::MethodOverride
      #  use Rack::CommonLogger, $stderr
      #  run inner_app
      #end.to_app
    end
  end
end
