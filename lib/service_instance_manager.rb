class ServiceInstanceManager
  class ServiceInstanceNotFound < StandardError; end
  class ServiceInstanceAlreadyAttached < StandardError; end
  class ServicePlanNotFound < StandardError; end
  class InvalidServicePlanUpdate < StandardError; end

  DATABASE_PREFIX = 'cf_'.freeze

  def self.create(opts)
    guid = opts[:guid]
    plan_guid = opts[:plan_guid]
    attach_guid = opts[:attach_guid]
    datacenter = opts[:datacenter]

    unless Catalog.has_plan?(plan_guid)
      raise "Plan #{plan_guid} was not found in the catalog."
    end

    max_storage_mb = Catalog.storage_quota_for_plan_guid(plan_guid)

    if guid =~ /[^0-9,a-z,A-Z$-]+/
      raise 'Only GUIDs matching [0-9,a-z,A-Z$-]+ are allowed'
    end

    db_name = database_name_from_service_instance_guid(guid)

    if attach_guid != NIL
      instance = ServiceInstance.find_by_guid(attach_guid)
      raise ServiceInstanceNotFound if instance.nil?
      db_name = instance.db_name
    else
      Database.create(db_name)
    end

    ServiceInstance.create(guid: guid, plan_guid: plan_guid, max_storage_mb: max_storage_mb, db_name: db_name, datacenter: datacenter)
  end

  def self.set_plan(opts)
    guid = opts[:guid]
    plan_guid = opts[:plan_guid]

    unless Catalog.has_plan?(plan_guid)
      raise ServicePlanNotFound.new("Plan #{plan_guid} was not found in the catalog.")
    end

    instance = ServiceInstance.find_by_guid(guid)
    raise ServiceInstanceNotFound if instance.nil?

    if Database.usage(instance.db_name) > Catalog.storage_quota_for_plan_guid(plan_guid)
      raise InvalidServicePlanUpdate.new('Downgrading this service instance will violate the quota of the new plan')
    end

    instance.plan_guid = plan_guid
    instance.max_storage_mb = Catalog.storage_quota_for_plan_guid(plan_guid)
    instance.save
  end

  def self.destroy(opts)
    guid = opts[:guid]
    instance = ServiceInstance.find_by_guid(guid)
    raise ServiceInstanceNotFound if instance.nil?
    db_name = instance.db_name
    instance.destroy

    if ServiceInstance.where(db_name: db_name).count == 0
      Database.drop(db_name)
    end
  end

  def self.database_name_from_service_instance_guid(guid)
    "#{DATABASE_PREFIX}#{guid.gsub('-', '_')}"
  end

  def self.sync_service_instances
    Catalog.plans.each do |plan|
      service_instances = ServiceInstance.where(plan_guid: plan.id)
      service_instances.update_all(max_storage_mb: plan.max_storage_mb)
    end
  end
end
