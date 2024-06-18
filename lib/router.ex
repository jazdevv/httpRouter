defmodule Router do
  require Router

  def init_Router() do
    {:ok, bucket} = Router.Bucket.start_link([])
    Process.put(:router, bucket)
  end

  def add_route(path, callback_function) when is_binary(path) do
    # get existing routes config
    routes_config = Router.Bucket.get(Process.get(:router))

    # split route into keys
    new_route_keys = String.split(path, "/")

    # generate new route config with the new route
    routes_config = build_routes_config(new_route_keys, routes_config, callback_function)

    # Update the config map at Router Bucket
    Router.Bucket.set(Process.get(:router), routes_config)

    # Log data
    IO.puts("new config map build")
    IO.inspect(routes_config)
  end

  defp build_routes_config([], acc, callback_function) do
    acc
  end

  defp build_routes_config([key | keys], acc, callback_function) do
    # if its not the last key
    if length(keys) > 0 do
      IO.puts("analyzing key: #{key}")
      # IO.puts("actual acc #{inspect(acc)}")
      case Map.get(acc, key) do
        nil ->
          Map.put(acc, format_key(key), build_routes_config(keys, %{}, callback_function))

        existing_map when is_map(existing_map) ->
          Map.put(acc, format_key(key), build_routes_config(keys, existing_map, callback_function))

        _ ->
          acc
      end
    else
      # When there are no more keys to process so its the last key, return the accumulator with the callback function.
      Map.put(acc, format_key(key), callback_function)
    end
  end

  defp format_key(key) do
    trimmed_key = String.trim(key)

    if String.starts_with?(trimmed_key, "{") && String.ends_with?(trimmed_key, "}") do
      "dynamic"
    else
      trimmed_key
    end
  end

  def add_route(path, callback_function) do
    raise ArgumentError, message: "Input must be a string"
  end
end
