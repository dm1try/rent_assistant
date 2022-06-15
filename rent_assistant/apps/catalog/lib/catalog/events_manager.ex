defmodule Catalog.EventsManager do
  @channel_name "events"

  def start_link(args) do
    name = Keyword.get(args, :name, CatalogEventsManager)

    {:ok, _} =
      Registry.start_link(
        keys: :duplicate,
        name: name,
      )
  end

  def subscribe(manager) do
    {:ok, _} = Registry.register(manager, @channel_name, [])
  end

  def notify(manager, event_name, event_data) do
    Registry.dispatch(manager, @channel_name, fn entries ->
      for {pid, _} <- entries, do: send(pid, {event_name, event_data})
    end)
  end
end
