defmodule PlaywrightEx.FrameWaiterTest do
  use ExUnit.Case, async: true

  alias PlaywrightEx.FrameWaiter

  test "evaluate load-state waiter completes when state reached" do
    waiter = FrameWaiter.new_load_state_waiter("load")
    frame_state = %{url: "about:blank", load_states: MapSet.new(["load"])}

    assert {:done, {:ok, nil}} = FrameWaiter.evaluate(waiter, frame_state)
  end

  test "evaluate url waiter transitions and then completes on load-state" do
    waiter = FrameWaiter.new_url_waiter(&(&1 == "about:blank#ok"), "load")

    assert {:update, waiter} =
             FrameWaiter.evaluate(waiter, %{url: "about:blank", load_states: MapSet.new(["commit"])})

    assert {:update, waiter} =
             FrameWaiter.evaluate(waiter, %{url: "about:blank#ok", load_states: MapSet.new(["commit"])})

    assert {:done, {:ok, nil}} =
             FrameWaiter.evaluate(waiter, %{url: "about:blank#ok", load_states: MapSet.new(["load"])})
  end

  test "evaluate returns error when url matcher raises" do
    waiter = FrameWaiter.new_url_waiter(fn _url -> raise "boom" end, "load")
    frame_state = %{url: "about:blank", load_states: MapSet.new(["commit"])}

    assert {:error, {:error, %{message: "boom"}}} = FrameWaiter.evaluate(waiter, frame_state)
  end

  test "update_load_states adds and removes states without aliases" do
    load_states =
      MapSet.new()
      |> FrameWaiter.update_load_states(%{add: "networkidle"})
      |> FrameWaiter.update_load_states(%{add: :load})
      |> FrameWaiter.update_load_states(%{remove: "networkidle"})

    assert MapSet.member?(load_states, "load")
    refute MapSet.member?(load_states, "networkidle")
  end
end
