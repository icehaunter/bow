defmodule Bow.DownloadTest do
  use ExUnit.Case
  import Mock

  @file_cat "test/files/cat.jpg"

  import Bow.Download, only: [download: 1]

  def mocked_get(url, _headers, _options) do
    case url do
      "http://example.com/cat.png" ->
        {:ok, %HTTPoison.Response{
          status_code: 200,
          request_url: url,
          body: File.read!(@file_cat),
          headers: [{"Content-Type", "image/png"}]
        }}

      "http://example.com/notype.png" ->
        {:ok, %HTTPoison.Response{
          status_code: 200,
          request_url: url,
          body: File.read!(@file_cat)
        }}

      "http://example.com/noext" ->
        {:ok, %HTTPoison.Response{
          status_code: 200,
          request_url: url,
          body: File.read!(@file_cat)
        }}

      "http://example.com/u" <> _ ->
        {:ok, %HTTPoison.Response{
          status_code: 200,
          request_url: url,
          body: File.read!(@file_cat),
          headers: [{"Content-Type", "image/png"}]
        }}

      "http://example.com/dog.jpg" ->
        {:ok, %HTTPoison.Response{
          status_code: 200,
          request_url: url,
          body: File.read!(@file_cat),
          headers: [{"Content-Type", "example/dog/nope"}]
        }}

      _ ->
        {:error, %HTTPoison.Error{reason: "Not Found"}}
    end
  end

  test "regular file" do
    with_mock(HTTPoison, [get: &mocked_get/3]) do
      assert {:ok, file} = download("http://example.com/cat.png")
      assert file.name == "cat.png"
      assert file.path != nil
      assert File.read!(file.path) == File.read!(@file_cat)
    end
  end

  test "file without content type" do
    with_mock(HTTPoison, [get: &mocked_get/3]) do
      assert {:ok, file} = download("http://example.com/notype.png")
      assert file.name == "notype.png"
      assert file.path != nil
      assert File.read!(file.path) == File.read!(@file_cat)
    end
  end

  test "file without extension" do
    with_mock(HTTPoison, [get: &mocked_get/3]) do
      assert {:ok, file} = download("http://example.com/noext")
      assert file.name == "noext"
      assert file.path != nil
      assert File.read!(file.path) == File.read!(@file_cat)
    end
  end

  test "file with invalid content type" do
    with_mock(HTTPoison, [get: &mocked_get/3]) do
      assert {:ok, file} = download("http://example.com/dog.jpg")
      assert file.name == "dog.jpg"
      assert file.path != nil
      assert File.read!(file.path) == File.read!(@file_cat)
    end
  end

  test "file not found" do
    with_mock(HTTPoison, [get: &mocked_get/3]) do
      assert {:error, "Not Found"} = download("http://example.com/nope")
    end
  end

  test "dynamic URL" do
    with_mock(HTTPoison, [get: &mocked_get/3]) do
      assert {:ok, file} = download("http://example.com/u/91372?v=3&s=460")
      assert file.name == "91372.png"
    end
  end
end
