module Configuration
  extend self

  def documentation_url
    Settings.services.first.metadata.documentationUrl rescue nil
  end

  def support_url
    Settings.services.first.metadata.supportUrl rescue nil
  end

  def manage_user_profile_url
    "#{auth_server_url}/profile"
  end

  def auth_server_url
    cc_api_info["authorization_endpoint"]
  end

  def auth_server_logout_url
    "#{cc_api_info["authorization_endpoint"]}/logout.do"
  end

  def token_server_url
    cc_api_info["token_endpoint"]
  end

  def cc_api_info
    return store[:cc_api_info] unless store[:cc_api_info].nil?

    cc_client = CloudControllerHttpClient.new
    response = cc_client.get('/info')

    store[:cc_api_info] = response
  end

  def store
    @store ||= {}
  end

  def clear
    store.clear
  end
end
