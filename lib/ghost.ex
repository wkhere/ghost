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

  def gists() do
    get("/users/#{config["me"]}/gists").body
  end
end
