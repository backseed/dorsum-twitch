require "log"
require "uri"
require "http"
require "json"

module Dorsum
  module Twitch
    module Api
      class Authentication
        BASE_URL = "https://id.twitch.tv/oauth2/token"

        property config : Dorsum::Config
        property access_token : (String | Nil)
        property expires_in : (Int32 | Nil)
        property expires_at : (Time::Span | Nil)
        property error : (String | Nil)

        def initialize(@config)
          @access_token = nil
          @expires_in = nil
          @error = nil
        end

        def expired?
          return false unless expires_at

          Time.monotonic > expires_at.as(Time::Span)
        end

        def perform
          response = HTTP::Client.post(url, headers: headers)
          Log.info { "GET #{url} -> #{response.status_code}" }
          if response.status_code >= 200 && response.status_code < 300
            json = JSON.parse(response.body)
            self.access_token = json["access_token"].as_s
            self.expires_in = json["expires_in"].as_i
            self.expires_at = Time.monotonic + Time::Span.new(seconds: expires_in.as(Int32))
            true
          else
            self.error = response.body
            false
          end
        end

        def url
          "#{BASE_URL}?#{query}"
        end

        private def query
          query = URI::Params.new
          params.each do |name, value|
            query.add(name, value)
          end
          query.to_s
        end

        private def params
          {
            "client_id"     => @config.client_id.to_s,
            "client_secret" => @config.client_secret.to_s,
            "grant_type"    => "client_credentials",
          }
        end

        private def headers
          headers = HTTP::Headers.new
          headers["User-Agent"] = "Dorsum"
          headers
        end
      end
    end
  end
end
