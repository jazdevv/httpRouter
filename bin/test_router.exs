require Router
require Router.Bucket

Router.init_Router()
Router.add_route("route/auth/user/5", fn -> IO.puts("hey from anonymous func") end)
Router.add_route("route/auth/user/6", fn -> IO.puts("hey from anonymous func") end)
Router.add_route("route/auth/user/{userid}", fn -> IO.puts("hey from anonymous func") end)
Router.add_route("route/auth2/user/{userid}", fn -> IO.puts("hey from anonymous func") end)
