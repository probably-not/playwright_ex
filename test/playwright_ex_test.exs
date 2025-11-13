defmodule PlaywrightExTest do
  use ExUnit.Case, async: true

  alias PlaywrightEx.Browser
  alias PlaywrightEx.BrowserContext
  alias PlaywrightEx.Config
  alias PlaywrightEx.Frame
  alias PlaywrightEx.Selector

  doctest PlaywrightEx

  @tag :tmp_dir
  test "visit elixir-lang.org and assert title", %{tmp_dir: tmp_dir} do
    browser_id = PlaywrightEx.launch_browser(:chromium)
    on_exit(fn -> Browser.close(browser_id) end)
    {:ok, context_id} = Browser.new_context(browser_id)
    if !System.get_env("CI"), do: on_exit_open_trace(context_id, tmp_dir)

    {:ok, page_id} = BrowserContext.new_page(context_id)
    frame_id = PlaywrightEx.initializer(page_id).main_frame.guid
    {:ok, _} = Frame.goto(frame_id, "https://elixir-lang.org/")

    assert_has(frame_id, Selector.role("heading", "Elixir is a dynamic, functional language"))
    refute_has(frame_id, Selector.role("heading", "I made this up"))

    {:ok, _} = Frame.click(frame_id, Selector.link("Install"))
    assert_has(frame_id, Selector.link("macOS"))
  end

  defp assert_has(frame_id, selector) do
    assert_expect(frame_id, selector, invert: false)
  end

  defp refute_has(frame_id, selector) do
    assert_expect(frame_id, selector, invert: true)
  end

  defp assert_expect(frame_id, selector, invert: invert?) do
    {:ok, result} = Frame.expect(frame_id, selector: selector, is_not: invert?, expression: "to.be.visible")
    assert result != invert?, "expected#{if invert?, do: " not"} to find #{selector}"
  end

  defp on_exit_open_trace(context_id, tmp_dir) do
    {:ok, _} = BrowserContext.start_tracing(context_id)
    trace_file = Path.join(tmp_dir, "trace.zip")

    on_exit(fn ->
      BrowserContext.stop_tracing(context_id, trace_file)

      spawn(fn ->
        args = ["playwright", "show-trace", trace_file]
        System.cmd(Config.global(:runner), args, cd: Config.global(:assets_dir))
      end)
    end)
  end
end
