require 'socket'
require 'pp'
require 'ghost'

module Ghost::Server

  Port = 64738
  
  module_function

  def listen()
    Ghost.conn
    server = TCPServer.new Port
    Process.daemon
    loop do
      conn = server.accept
      case (data = parse(conn.gets))
      when nil, [] 
        conn.puts "gimme sth"
      else
        encode(invoke(data), conn)
      end
      conn.close
    end
  end

  def parse(data)
    data.split if data
  end

  def invoke(cmd)
    Ghost.send cmd[0].to_sym, *cmd[1..-1]
  end

  def encode(result, io)
    PP.pp(result, io)
  end
end
