class AddDatacenterToServiceInstances < ActiveRecord::Migration
  def change
    add_column :service_instances, :datacenter, :string
    add_index :service_instances, [:datacenter, :db_name], :unique => true
  end
end
