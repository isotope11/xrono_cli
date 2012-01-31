module Xcli
  class Configuration
    attr_accessor :url, :email, :password

    def initialize
      load_config
    end

    private

    def load_config
      config_file = File.expand_path '~/.xronorc'
      if File.exist? config_file
        @config = YAML.load_file config_file
      else
        @config = {}
      end

      self.url = @config.fetch('url', 'http://127.0.0.1:3000')
      self.email = @config.fetch('email', 'dev@xrono.org')
      self.password = @config.fetch('password', '123456')

      @config
    end
  end
end

