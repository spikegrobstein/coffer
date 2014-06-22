require 'net/http'
require 'json'

module Coffer
  class Client
    attr_accessor :port, :host, :username, :password

    def initialize( host, port , username, password )
      @port = port
      @host = host
      @username = username
      @password = password
    end

    def method_missing(name, *args)
      post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
      resp = JSON.parse( http_post_request(post_body) )
      raise JSONRPCError, resp['error'] if resp['error']
      resp['result']
    end

    def http_post_request(post_body)
      http    = Net::HTTP.new(host, port)
      request = Net::HTTP::Post.new('/')
      request.basic_auth username, password
      request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    end

    class JSONRPCError < RuntimeError; end
  end
end

