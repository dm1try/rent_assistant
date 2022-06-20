defmodule TgBot.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table("chats") do
      add(:chat_id, :integer)
      add(:notified_at, :utc_datetime)
      add(:active, :boolean, default: false)
      add(:filters, :map, default: %{})

      timestamps()
    end
  end
end
