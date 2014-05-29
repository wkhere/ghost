defmodule Ghost.Config do
  def from_file() do
    File.stream!(System.user_home<>"/.ghostrc")
      |> Enum.reduce [], fn(l,acc)->
        [ process_line(l) | acc ]
      end
  end
  defp process_line(line) do
    [k,v] = line |> String.rstrip |> String.split("=")
    {String.strip(k) |> binary_to_atom, String.strip(v)}
  end

  def register() do
    :ets.new(:ghost, [:named_table])
    :ets.insert(:ghost, {:config, from_file})
  end

  def get() do
    [{:config, v}] = :ets.lookup(:ghost, :config)
    v
  end

end


defmodule Ghost.Server do
  @port 64738

  def main([]), do: main([@port])
  def main([port]) when is_binary(port) do
    {port, ""} = Integer.parse(port)
    main([port])
  end
  def main([port]) when is_integer(port) do
    Ghost.Config.register
    listen(port)
  end

  def listen(port \\ @port) do
    case :gen_tcp.listen(port, [:binary, packet: :line, active: false]) do
      {:ok, master} -> accept_loop(master)
      _ -> System.halt(2)
    end
  end

  def accept_loop(socket) do
    {:ok, conn_socket} = :gen_tcp.accept(socket)
    spawn(fn-> conn_loop(conn_socket) end)
    accept_loop(socket)
  end

  def conn_loop(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        resp = case data |> parse do
          []  -> "gimme sth"
          cmd -> cmd |> invoke |> encode
        end
        # todo: above in monadic style
        :gen_tcp.send(socket, resp<>"\n")
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
    inspect(result, pretty: true)
  end
end
