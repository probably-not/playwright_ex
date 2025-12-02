ExUnit.start()
{:ok, _} = PlaywrightEx.Supervisor.start_link(Application.get_all_env(:playwright_ex))
