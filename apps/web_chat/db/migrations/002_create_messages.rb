Sequel.migration do
  change do
    create_table(:messages) do
      primary_key :id
      foreign_key :chat_id, :chats, null: false, on_delete: :cascade
      String :content, text: true, null: false
      DateTime :created_at, null: false
    end
  end
end
