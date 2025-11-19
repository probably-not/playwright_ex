defmodule PlaywrightEx.BrowserType do
  @moduledoc """
  Interact with a Playwright `BrowserType`.

  There is no official documentation, since this is considered Playwright internal.

  References:
  - https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/client/browserType.ts
  """

  alias PlaywrightEx.ChannelResponse
  alias PlaywrightEx.Connection

  def launch(type_id, opts \\ []) do
    %{guid: type_id, method: :launch, params: Map.new(opts)}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap_create(:browser)
  end
end
