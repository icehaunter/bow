defmodule Bow.Download do

  @http_adapter Application.get_env(:bow, :http_adapter, HTTPoison)

  @doc """
  Download file from given URL
  """
  @spec download(url :: String.t, headers :: Keyword.t()) :: {:ok, Bow.t} | {:error, any}
  def download(url, headers \\ []) do
    url
    |> encode
    |> @http_adapter.get(headers, follow_redirect: true, max_redirect: 5)
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body, request_url: url}} ->
        base = url |> URI.parse |> Map.get(:path) |> Path.basename

        name =
          headers
          |> Enum.find_value(nil, fn {"Content-Type", type} -> type end)
          |> MIME.extensions
          |> case do
            [ext | _] -> Path.rootname(base) <> "." <> ext
            _ -> base
          end

        path = Plug.Upload.random_file!("bow-download")
        case File.write(path, body) do
          :ok ->
            {:ok, Bow.new(name: name, path: path)}

          {:error, reason} ->
            {:error, reason}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp encode(url), do: url |> URI.encode() |> String.replace(~r/%25([0-9a-f]{2})/i, "%\\g{1}")
  # based on: https://stackoverflow.com/questions/31825687/how-to-avoid-double-encoding-uri
end
