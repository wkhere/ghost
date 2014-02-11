require 'faraday'
require 'json'

module Ghost
  module_function
  def conn()
    @conn ||= Faraday.new(url: "https://api.github.com") do |client|
      #client.response :logger
      client.adapter Faraday.default_adapter
    end.tap do |conn|
      @config = Hash.new.tap do |h|
        File.open(ENV['HOME']+'/.ghostrc') do |f| 
        while(s = f.gets) do
          k, v = process_line(s)
          h[k] = v
        end; end
      end
      conn.basic_auth @config['tok'], 'x-oauth-basic'
    end
  end

  def get(*args) JSON.parse(conn.get(*args).body) end

  def config() @config end

  def gists()
    get("/users/#{@config['me']}/gists")
  end
 
  def del() @conn=nil end #tmp

  def process_line(line)
    line.chomp.split('=').map &:strip
  end
end
