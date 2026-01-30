import Config

import_config "#{config_env()}.exs"

config :playwright_ex, fail_on_unknown_opts: false
