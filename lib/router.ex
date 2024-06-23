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
    # IO.inspect(routes_config)

    IO.puts("Added route: #{path}")
  end

  def get_route_callback(path) do
    route_keys = String.split(path, "/")

    routes_config = Router.Bucket.get(Process.get(:router))
    data = read_routes_config(route_keys, routes_config, %{:callback => nil})
    IO.inspect(data)
  end

  defp read_routes_config([key, keys], acc, data) do
    case Map.get(acc, key) do
      nil ->
        case Map.get(acc, :dynamic) do
          nil ->
            data

          value ->
            data
        end

      value ->
        data
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

  def add_route(path, callback_function) do
    raise ArgumentError, message: "Input must be a string"
  end
end
