defmodule TgBot.Controller do
  use Telegram.Bot

  def handle_update(
        %{
          "message" => %{
            "text" => "/start",
            "chat" => %{"id" => chat_id},
            "message_id" => message_id
          }
        },
        token
      ) do
    if chat = TgBot.Repo.get_by(TgBot.Chat, %{chat_id: chat_id}) do
      chat = Ecto.Changeset.change(chat, active: true)
      TgBot.Repo.update(chat)
    else
      TgBot.Repo.insert(%TgBot.Chat{chat_id: chat_id, active: true})
    end

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: "I'll notify you about new listings"
    )
  end

  def handle_update(
        %{
          "message" => %{
            "text" => "/stop",
            "chat" => %{"id" => chat_id},
            "message_id" => message_id
          }
        },
        token
      ) do
    if chat = TgBot.Repo.get_by(TgBot.Chat, %{chat_id: chat_id}) do
      chat = Ecto.Changeset.change(chat, active: false)
      TgBot.Repo.update(chat)
    end

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: "I'm stopping to notify you about new listings. Feel free to start me again."
    )
  end

  def handle_update(
        %{
          "message" => %{
            "text" => "/info",
            "chat" => %{"id" => chat_id},
            "message_id" => message_id
          }
        },
        token
      ) do
    chat = TgBot.Repo.get_by(TgBot.Chat, %{chat_id: chat_id})

    info = "I'm currently #{if chat.active do
      "notifying"
    else
      "not notifying"
    end} about new listings"

    Telegram.Api.request(token, "sendMessage",
      chat_id: chat_id,
      text: info
    )
  end
end
