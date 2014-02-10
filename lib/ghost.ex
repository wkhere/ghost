defmodule Ghost do
  use HTTPotion.Base

  def process_url(url), do: "https://api.github.com" <> url
  def process_request_headers(hdrs), do: Dict.put(hdrs, "User-Agent", "ghost")

  def process_response_body(body) do
    body |> to_string |> :jsx.decode
  end
end
