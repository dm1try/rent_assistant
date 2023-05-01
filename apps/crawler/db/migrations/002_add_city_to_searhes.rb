Sequel.migration do
  change do
    add_column :searches, :city, String, null: false, default: 'warszawa'
  end
end
