defmodule PlaywrightEx.Supervisor do
  @moduledoc """
  Playwright connection supervision tree.
  """

  use Supervisor

  def start_link(opts \\ []) do
    opts =
      opts
      |> Keyword.validate!([:timeout, executable: "playwright", js_logger: nil])
      |> validate_executable!()

    Supervisor.start_link(__MODULE__, Map.new(opts), name: __MODULE__)
  end

  @impl true
  def init(%{timeout: timeout, executable: executable, js_logger: js_logger}) do
    children = [
      {PlaywrightEx.PortServer, executable: executable},
      {PlaywrightEx.Connection, [[timeout: timeout, js_logger: js_logger]]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  defp validate_executable!(opts) do
    error_msg = """
    Playwright executable not found.
    Ensure `playwright` executable is on `$PATH` or pass `executable` option
    'assets/node_modules/playwright/cli.js' or similar.
    """

    Keyword.update!(
      opts,
      :executable,
      &cond do
        path = System.find_executable(&1) -> path
        File.exists?(&1) -> &1
        true -> raise error_msg
      end
    )
  end
end
