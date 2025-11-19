defmodule PlaywrightExTest do
  use ExUnit.Case, async: true

  alias PlaywrightEx.Browser
  alias PlaywrightEx.BrowserContext
  alias PlaywrightEx.Frame
  alias PlaywrightEx.Selector
  alias PlaywrightEx.Tracing

  doctest PlaywrightEx

  @timeout Application.compile_env(:playwright_ex, :timeout)

  @tag :tmp_dir
  test "visit elixir-lang.org, then assert and navigate", %{tmp_dir: tmp_dir} do
    {:ok, browser} = PlaywrightEx.launch_browser(:chromium, timeout: @timeout)
    on_exit(fn -> Browser.close(browser.guid, timeout: @timeout) end)

    {:ok, context} = Browser.new_context(browser.guid, timeout: @timeout)
    if !System.get_env("CI"), do: on_exit_open_trace(context.tracing.guid, tmp_dir)

    {:ok, %{main_frame: frame}} = BrowserContext.new_page(context.guid, timeout: @timeout)
    {:ok, _} = Frame.goto(frame.guid, "https://elixir-lang.org/", timeout: @timeout)

    assert_has(frame.guid, Selector.role("heading", "Elixir is a dynamic, functional language"))
    refute_has(frame.guid, Selector.role("heading", "I made this up"))

    {:ok, _} = Frame.click(frame.guid, Selector.link("Install"), timeout: @timeout)
    assert_has(frame.guid, Selector.link("macOS"))
  end

  defp assert_has(frame_id, selector) do
    assert_expect(frame_id, selector, invert: false)
  end

  defp refute_has(frame_id, selector) do
    assert_expect(frame_id, selector, invert: true)
  end

  defp assert_expect(frame_id, selector, invert: invert?) do
    opts = [selector: selector, is_not: invert?, expression: "to.be.visible", timeout: @timeout]
    {:ok, result} = Frame.expect(frame_id, opts)
    assert result != invert?, "expected#{if invert?, do: " not"} to find #{selector}"
  end

  defp on_exit_open_trace(tracing_id, tmp_dir) do
    {:ok, _} = Tracing.tracing_start(tracing_id, timeout: @timeout)
    {:ok, _} = Tracing.tracing_start_chunk(tracing_id, timeout: @timeout)

    on_exit(fn ->
      {:ok, zip_file} = Tracing.tracing_stop_chunk(tracing_id, timeout: @timeout)
      {:ok, _} = Tracing.tracing_stop(tracing_id, timeout: @timeout)

      trace_file = Path.join(tmp_dir, "trace.zip")
      File.cp!(zip_file.absolute_path, trace_file)

      spawn(fn ->
        args = ["playwright", "show-trace", trace_file]
        System.cmd("npx", args, cd: "assets")
      end)
    end)
  end
end
