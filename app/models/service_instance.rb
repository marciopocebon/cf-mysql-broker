class ServiceInstance < ActiveRecord::Base
  def self.reserved_space_in_mb
    # we have 1 records per each datacenter, therefore dividing total reserved space by 2.
    self.sum(:max_storage_mb) / 2
  end
end
