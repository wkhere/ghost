defmodule Ghost do
  use HTTPotion.Base

  def process_url(url), do: "https://api.github.com" <> url
  def process_request_headers(hdrs), do: Dict.put(hdrs, "User-Agent", "ghost")

  def process_response_body(body) do
    body |> to_string |> :jsx.decode
  end

  def opts() do
    [ibrowse: [{:basic_auth, 
        {config["tok"] |> String.to_char_list!, 'x-oauth-basic'}}]]
  end

  def config() do
    File.stream!(Elixir.System.user_home<>"/.ghostrc")
      |> Enum.reduce [], fn(l,acc)->
        [ process_line(l) | acc ]
      end
  end
  defp process_line(line) do
    [k,v] = line |> String.rstrip |> String.split("=")
    {String.strip(k), String.strip(v)}
  end

  def get(url), do: get(url, [], opts)

  def gists(filter_row \\ &id/1, filter_col \\ &sel/1) do
    get("/users/#{config["me"]}/gists").body
    |> Enum.filter(filter_row)
    |> Enum.map(filter_col)
  end

  defp id(x), do: x

  def sel(gist, fields \\ ["id", "files", "public"]) do
    fields = HashSet.new fields
    gist |> Dict.to_list |> Enum.filter(fn {k, _v} ->
      Set.member?(fields, k)
    end)
  end

end
