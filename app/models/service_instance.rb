class ServiceInstance < ActiveRecord::Base
  def self.reserved_space_in_mb
    self.sum(:max_storage_mb)
  end

  def self.find_by_guid(guid)
    self.where("guid = ? or attached_instance_guid = ?", guid, guid).first
  end
end
