class AddAttachedInstanceGuidToServiceInstances < ActiveRecord::Migration
  def change
    add_column :service_instances, :attached_instance_guid, :string
    add_index :service_instances, :attached_instance_guid
    add_column :service_instances, :deleted, :boolean, default: false
  end
end
