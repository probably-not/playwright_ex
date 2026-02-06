defmodule PlaywrightEx.WebsocketTransportTest do
  @moduledoc """
  Tests that verify WebSocket transport works correctly.

  These tests use a Playwright Docker container started via testcontainers.
  """

  use WebsocketTransportCase, async: false

  alias PlaywrightEx.Frame

  describe "websocket transport" do
    test "can navigate and get page title", %{frame: frame, connection: connection} do
      {:ok, _} = Frame.goto(frame.guid, url: "https://example.com", timeout: @timeout, connection: connection)
      {:ok, title} = Frame.title(frame.guid, timeout: @timeout, connection: connection)

      assert title =~ "Example Domain"
    end

    test "can evaluate javascript", %{frame: frame, connection: connection} do
      {:ok, result} =
        Frame.evaluate(frame.guid,
          expression: "1 + 2",
          timeout: @timeout,
          connection: connection
        )

      assert result == 3
    end

    test "can upload files via set_input_files", %{frame: frame, connection: connection} do
      # Create a page with a file input
      {:ok, _} = Frame.goto(frame.guid, url: "about:blank", timeout: @timeout, connection: connection)

      {:ok, _} =
        Frame.evaluate(frame.guid,
          expression: """
          () => {
            const input = document.createElement('input');
            input.type = 'file';
            input.id = 'file-input';
            document.body.appendChild(input);
          }
          """,
          is_function: true,
          timeout: @timeout,
          connection: connection
        )

      # Create a temp file to upload
      tmp_path = Path.join(System.tmp_dir!(), "playwright-test-upload-#{System.unique_integer([:positive])}.txt")
      File.write!(tmp_path, "hello from elixir")

      try do
        # Upload the file via websocket (remote) connection
        {:ok, _} =
          Frame.set_input_files(frame.guid,
            selector: "#file-input",
            local_paths: [tmp_path],
            timeout: @timeout,
            connection: connection
          )

        # Verify the file was uploaded by reading it back via JS
        {:ok, file_name} =
          Frame.evaluate(frame.guid,
            expression: "() => document.getElementById('file-input').files[0].name",
            is_function: true,
            timeout: @timeout,
            connection: connection
          )

        {:ok, file_content} =
          Frame.evaluate(frame.guid,
            expression: "() => document.getElementById('file-input').files[0].text()",
            is_function: true,
            timeout: @timeout,
            connection: connection
          )

        assert file_name == Path.basename(tmp_path)
        assert file_content == "hello from elixir"
      after
        File.rm(tmp_path)
      end
    end
  end
end
