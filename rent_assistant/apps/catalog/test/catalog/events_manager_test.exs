defmodule CatalogEventsManagerTest do
  use ExUnit.Case, async: false

  test "it works" do
    {:ok, _pid} = Catalog.EventsManager.start_link(name: TestPublisher)
    Catalog.EventsManager.subscribe(TestPublisher)
    Catalog.EventsManager.notify(TestPublisher, :listing_created, %{id: 1})

    assert_receive {:listing_created, %{id: 1}}
  end
end
