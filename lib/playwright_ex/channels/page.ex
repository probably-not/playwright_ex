defmodule PlaywrightEx.Page do
  @moduledoc """
  Interact with a Playwright `Page`.

  There is no official documentation, since this is considered Playwright internal.

  References:
  - https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/client/page.ts
  """

  alias PlaywrightEx.ChannelResponse
  alias PlaywrightEx.Connection

  def update_subscription(page_id, opts \\ []) do
    %{guid: page_id, method: :update_subscription, params: Map.new(opts)}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap(& &1)
  end

  def screenshot(page_id, opts \\ []) do
    # Playwright options: https://playwright.dev/docs/api/class-page#page-screenshot
    params =
      opts
      |> Keyword.validate!(full_page: true, omit_background: false)
      |> Map.new()

    %{guid: page_id, method: :screenshot, params: params}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap(& &1.binary)
  end
end
