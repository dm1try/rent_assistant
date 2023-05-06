Sequel.migration do
  change do
    add_column :chats, :state, String, text: true, null: false, default: '{}'
  end
end
