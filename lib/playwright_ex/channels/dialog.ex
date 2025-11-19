defmodule PlaywrightEx.Dialog do
  @moduledoc """
  Interact with a Playwright `Dialog`.

  There is no official documentation, since this is considered Playwright internal.

  References:
  - https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/client/dialog.ts
  """

  alias PlaywrightEx.ChannelResponse
  alias PlaywrightEx.Connection

  def accept(dialog_id, opts \\ []) do
    %{guid: dialog_id, method: :accept, params: Map.new(opts)}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap(& &1)
  end

  def dismiss(dialog_id, opts \\ []) do
    %{guid: dialog_id, method: :dismiss, params: Map.new(opts)}
    |> Connection.send(opts[:timeout])
    |> ChannelResponse.unwrap(& &1)
  end
end
