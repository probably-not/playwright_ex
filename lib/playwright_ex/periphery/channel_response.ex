defmodule PlaywrightEx.ChannelResponse do
  @moduledoc false

  alias PlaywrightEx.Connection

  def unwrap(%{error: error}, _), do: {:error, error}
  def unwrap(%{result: result}, fun) when is_function(fun, 1), do: {:ok, fun.(result)}
  def unwrap(other, fun) when is_function(fun, 1), do: {:ok, other}

  def unwrap_create(value, resource_name) when is_atom(resource_name) do
    unwrap(value, fn result ->
      resource = Map.fetch!(result, resource_name)
      Map.merge(resource, Connection.initializer!(resource.guid))
    end)
  end
end
