defmodule Catalog.EventsManager do
  @channel_name "events"
  @default_name CatalogEventsManager

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(args) do
    name = Keyword.get(args, :name, @default_name)

    {:ok, _} =
      Registry.start_link(
        keys: :duplicate,
        name: name,
      )
  end

  def subscribe(manager \\ @default_name) do
    {:ok, _} = Registry.register(manager, @channel_name, [])
  end

  def notify(manager, event_name, event_data) do
    Registry.dispatch(manager, @channel_name, fn entries ->
      for {pid, _} <- entries, do: send(pid, {event_name, event_data})
    end)
  end
end
