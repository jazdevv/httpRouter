defmodule Router.Bucket do
  use Agent

  @doc """
  starts a new route storage
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  set the new router tuple
  """
  def set(bucket, router_tuple) do
    Agent.update(bucket, fn _ -> router_tuple end)
  end

  @doc """
  <!-- retrieves the router from the specific router -->
  """
  def get(bucket) do
    Agent.get(bucket, fn router_tuple -> router_tuple end)
  end
end
