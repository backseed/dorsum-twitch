require "uri"
require "http"
require "json"

module Dorsum
  module Twitch
    module Api
      class Client
        BASE_URL = "https://api.twitch.tv"

        property config : Dorsum::Config
        property authentication : Dorsum::Twitch::Api::Authentication

        def initialize(@config)
          @authentication = Dorsum::Twitch::Api::Authentication.new(@config)
        end

        def authenticate
          authentication.perform
        end

        def broadcaster_id(name)
          response = get(
            "/helix/users",
            {"login" => name}
          )
          if response.status_code >= 200 && response.status_code < 300
            data = JSON.parse(response.body)
            if data["data"].as_a.empty?
              Log.fatal { "Can't find broadcaster with account name `#{name}'" }
            else
              data["data"][0]["id"].as_s
            end
          end
        end

        def channel(broadcaster_id)
          response = get(
            "/helix/channels",
            {"broadcaster_id" => broadcaster_id}
          )
          if response.status_code >= 200 && response.status_code < 300
            JSON.parse(response.body)["data"][0]
          end
        end

        private def get(path, params : Hash(String, String))
          full_url = url(path, params)
          response = HTTP::Client.get(full_url, headers: headers)
          Log.info { "GET #{full_url} -> #{response.status_code}" }
          response
        end

        private def url(path, params : Hash(String, String))
          query = params.empty? ? "" : "?#{encode_query(params)}"
          "#{BASE_URL}#{path}#{query}"
        end

        private def encode_query(params : Hash(String, String))
          query = URI::Params.new
          params.each do |name, value|
            query.add(name, value)
          end
          query.to_s
        end

        private def headers
          headers = HTTP::Headers.new
          headers["User-Agent"] = "Dorsum"
          headers["Client-Id"] = config.client_id.as_s
          headers["Authorization"] = "Bearer #{authentication.access_token}"
          headers
        end
      end
    end
  end
end
