defmodule PlaywrightEx.Channel do
  @moduledoc false
  def timeout_opt, do: [type: :timeout, required: true, doc: "Maximum time for the operation (milliseconds)."]

  @debug_unknown true

  if @debug_unknown do
    def validate_known!(opts, schema) do
      NimbleOptions.validate!(opts, schema)
    end
  else
    def validate_known!(opts, schema) do
      {known, unknown} = Keyword.split(opts, Keyword.keys(schema.schema))
      NimbleOptions.validate!(known, schema) ++ unknown
    end
  end
end
