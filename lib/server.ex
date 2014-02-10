defmodule Ghost.Server do
  @port 64738

  def listen(port \\ @port) do
    {:ok, master} = :gen_tcp.listen(port, [:binary, packet: :line, active: false])
    accept_loop(master)
  end

  def accept_loop(socket) do
    {:ok, conn_socket} = :gen_tcp.accept(socket)
    spawn(fn-> conn_loop(conn_socket) end)
    accept_loop(socket)
  end

  def conn_loop(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        res = case data |> parse do
          []  -> "gimme sth"
          cmd -> :error_logger.info_msg "* got:" <> inspect(cmd) 
            cmd |> invoke
        end
        # todo: above in monadic style
        :gen_tcp.send(socket, res |> encode)
        conn_loop(socket)
      {:error, :closed} -> :ok
    end
  end

  def parse(data) do
    String.split data
  end

  def invoke(cmd) do
    [ fun | args ] = cmd
    apply(Ghost, binary_to_atom(fun), args)
  end

  def encode(result) do
    inspect(result) <> "\n"
  end
end
