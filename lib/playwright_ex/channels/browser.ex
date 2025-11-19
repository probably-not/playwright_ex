defmodule PlaywrightEx.Browser do
  @moduledoc """
  Interact with a Playwright `Browser`.

  There is no official documentation, since this is considered Playwright internal.

  References:
  - https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/client/browser.ts
  """

  alias PlaywrightEx.ChannelResponse
  alias PlaywrightEx.Connection

  def new_context(browser_id, opts \\ []) do
    params = Map.new(opts)

    %{guid: browser_id, method: :new_context, params: params}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap_create(:context)
  end

  def close(browser_id, opts \\ []) do
    params = Map.new(opts)

    %{guid: browser_id, method: :close, params: params}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap(& &1)
  end
end
