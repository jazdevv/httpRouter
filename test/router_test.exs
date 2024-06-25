defmodule RouterTest do
  use ExUnit.Case
  doctest Router

  test "router: init router" do
    Router.init_Router()
    assert is_pid(Process.get(:router))
  end

  test "router: add and retrieve routes" do
    Router.init_Router()
    string = "hey from anonymous func"
    callback_fn = fn -> IO.puts(string) end

    Router.add_route("route/auth/user", callback_fn)
    data = Router.get_route_callback("route/auth/user")
    assert(Map.get(data, :callback, nil) == callback_fn)
  end

end
