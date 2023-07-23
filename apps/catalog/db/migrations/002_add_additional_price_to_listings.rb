Sequel.migration do
  change do
    add_column :listings, :additional_price, Integer, default: 0
  end
end
