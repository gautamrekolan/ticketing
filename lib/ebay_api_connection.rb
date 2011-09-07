class EbayApiConnection
  def self.connection
    @@connection ||= connect!
  end
  
  def self.connect!
    config = YAML::load(File.open(Rails.root.to_s + "/config/ebay_trading_api.yml"))
    config = config["production"]
    Ebay::Api::Trading.new(config["url"], config["auth_token"], config["app_name"], config["cert_name"], config["dev_name"], config["compatibility_level"].to_s)  
  end
end

