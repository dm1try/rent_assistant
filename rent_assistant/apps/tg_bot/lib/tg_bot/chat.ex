defmodule TgBot.Chat do
  use Ecto.Schema

  schema "chats" do
    field(:chat_id, :integer)
    field(:notified_at, :utc_datetime)
    field(:active, :boolean)
    field(:filters, :map)

    timestamps()
  end
end
