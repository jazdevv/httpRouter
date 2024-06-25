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

    IO.puts("Added route: #{path}")
  end

  def add_route(_, _) do
    raise ArgumentError, message: "Input must be a string"
  end

  def get_route_callback(path) do
    route_keys = String.split(path, "/")

    routes_config = Router.Bucket.get(Process.get(:router))
    data = read_routes_config(route_keys, routes_config, %{:callback => nil, :dynamic => []})

    IO.inspect("result of the path #{path}: #{inspect(data)}")
  end

  defp read_routes_config([], acc, data) do
    read_config_nokey(nil, [] , acc, data)
  end


  defp read_routes_config([key | keys], acc, data) do
    case Map.get(acc, key) do
      nil ->
        read_config_nokey(key, keys , acc, data)
      map ->
        read_routes_config(keys, map, data)
    end
  end

  defp read_config_nokey(key, _, acc, data) do
    case Map.get(acc, :dynamic) do
      nil ->
        case Map.get(acc, :default) do
          value when is_function(value) ->
            Map.put(data, :callback, value)
          _ ->
            data
        end

      _ ->
        map_with_dynamic = Map.put(data, :dynamic, [key] ++ Map.get(data, :dynamic))

        case Map.get(acc, :default) do
          value when is_function(value) ->
            Map.put(map_with_dynamic, :callback, value)
          _ ->
            Map.put(map_with_dynamic, :dynamic, [key] ++ Map.get(data, :dynamic))
        end
    end
  end

  defp build_routes_config([], acc, callback_function) do
    Map.put(acc, :default, callback_function)
  end

  defp build_routes_config([key | keys], acc, callback_function) do
    case Map.get(acc, key) do
      nil ->
        Map.put(acc, format_key(key), build_routes_config(keys, %{}, callback_function))

      existing_map when is_map(existing_map) ->
        Map.put(acc, format_key(key), build_routes_config(keys, existing_map, callback_function))

      _ ->
        acc
    end
  end

  defp format_key(key) do
    trimmed_key = String.trim(key)

    if String.starts_with?(trimmed_key, "{") && String.ends_with?(trimmed_key, "}") do
      :dynamic
    else
      trimmed_key
    end
  end

end
