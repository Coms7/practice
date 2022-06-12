
require 'aws-sdk-secretsmanager'
require 'base64'

def get_secret
  @aws_secret_client = Aws::SecretsManager::Client.new(region: ENV['AWS_SECRET_REGION'])
    begin
  get_secret_value_response = client.get_secret_value(secret_id: secret_name)
	secret = JSON.parse(get_secret_value_response.secret_string)
	secret['sample']
	puts secret
end
