Sequel.migration do
  change do
    create_table(:searches) do
      primary_key :id
      String :filters, text: true, null: false
    end
  end
end
