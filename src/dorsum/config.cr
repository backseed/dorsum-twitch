require "yaml"
require "file_utils"

module Dorsum
  class Config
    PATH     = Path["~/.config/dorsum"].expand(home: true)
    FILENAME = PATH.join("config.yml")

    ATTRIBUTES = %w[
      client_id
      client_secret
      username
      password
    ]

    property data : Hash(String, YAML::Any)

    def initialize
      @data = {} of String => YAML::Any
    end

    def initialize(data : YAML::Any)
      @data = {} of String => YAML::Any
      ATTRIBUTES.each do |attribute|
        value = data[attribute]?
        @data[attribute] = value if value
      end
    end

    def initialize(data : Hash(String, YAML::Any | String))
      @data = {} of String => YAML::Any
      ATTRIBUTES.each do |attribute|
        value = data[attribute]?
        @data[attribute] = YAML::Any.new(value) if value
      end
    end

    def save(path = FILENAME)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, "wb") { |file| file << YAML.dump(@data) }
    end

    def self.load(path = FILENAME)
      if File.exists?(path)
        Config.new(YAML.parse(File.read(path)))
      else
        Config.new
      end
    end

    {% for name in ATTRIBUTES %}
      def {{name.id}} : YAML::Any
        @data[{{name}}]
      end

      def {{name.id}}? : (YAML::Any | Nil)
        @data.fetch({{name}}, nil)
      end

      def {{name.id}}=(value : String)
        @data[{{name}}] = YAML::Any.new(value)
      end

      def {{name.id}}=(value : YAML::Any)
        @data[{{name}}] = value
      end
    {% end %}
  end
end
