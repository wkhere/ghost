defmodule Ghost do
  use HTTPotion.Base
  alias Ghost.Config

  def process_url(url), do: "https://api.github.com" <> url
  def process_request_headers(hdrs), do: Dict.put(hdrs, :"User-Agent", "ghost")

  def process_response_body(body) do
    body |> to_string |> :jsx.decode
  end

  def opts() do
    [ibrowse: [{:basic_auth, 
        {Config.get[:tok] |> List.from_char_data!, 'x-oauth-basic'}}]]
  end

  def get(url), do: get(url, [], opts)

  def gists(filter_row \\ &id/1, filter_col \\ &sel/1) do
    get("/users/#{Config.get[:me]}/gists").body
    |> Enum.filter(filter_row)
    |> Enum.map(filter_col)
  end

  defp id(x), do: x

  def sel(gist, fields \\ ["id", "files", "public"]) do
    fields = fields |> Enum.into HashSet.new
    gist |> Dict.to_list |> Enum.filter(fn {k, _v} ->
      Set.member?(fields, k)
    end)
  end

end
