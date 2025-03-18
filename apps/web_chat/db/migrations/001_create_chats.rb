Sequel.migration do
  change do
    create_table(:chats) do
      primary_key :id
      Boolean :active, null: false, default: false
      DateTime :notified_at
      String :filters, text: true, null: false, default: '{}'
      String :state, text: true, null: false, default: '{}'
    end
  end
end
