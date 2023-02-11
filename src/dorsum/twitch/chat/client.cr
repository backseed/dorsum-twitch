require "log"
require "socket"
require "openssl"
require "./connection"

module Dorsum
  module Twitch
    module Chat
      class Client < Dorsum::Twitch::Chat::Connection
        HOST = "irc.chat.twitch.tv"
        PORT = 6697_u16

        def connect
          tcp_socket = TCPSocket.new(HOST, PORT)
          tcp_socket.read_timeout = 15
          tcp_socket.write_timeout = 5

          # Configure pretty agressive keepalive settings so detect dead connections.
          tcp_socket.keepalive = true
          tcp_socket.tcp_keepalive_idle = 20
          tcp_socket.tcp_keepalive_interval = 1
          tcp_socket.tcp_keepalive_count = 3

          Log.info { "Connecting to #{HOST}…" }
          @socket = OpenSSL::SSL::Socket::Client.new(tcp_socket)
          # Prevent other code from using the socket before it established completely by interacting with it.
          @socket.as(OpenSSL::SSL::Socket::Client).unbuffered_flush
          self
        end

        def socket
          raise "Client is not connected, please call #connect." if @socket.nil?
          @socket.as(OpenSSL::SSL::Socket::Client)
        end

        def gets
          line = socket.gets
          Log.debug { "< #{line}" } if line
          line
        end

        def puts(data : String)
          line = data.strip
          Log.debug { "> #{line}" }
          socket.puts line
          socket.puts "\r\n"
          socket.flush
        end

        def close
          socket.close
          @socket = nil
        end
      end
    end
  end
end
