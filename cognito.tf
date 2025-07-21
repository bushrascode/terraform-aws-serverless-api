// main user directory - database of users managed by AWS. - your users will live here — with their passwords, attributes, etc.
resource "aws_cognito_user_pool" "pool" {
  name = "mypool"
}

// this represents an application (like Postman, your website, or a mobile app) that wants to authenticate users using your user pool
resource "aws_cognito_user_pool_client" "client" {
  name                                 = "cognito_client"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  allowed_oauth_flows_user_pool_client = true // this app will use OAuth 2.0 to log users in
  generate_secret = false 
  allowed_oauth_flows = ["implicit", "code"] // 0Auth flows
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"] // login methods allowed outside OAuth
  supported_identity_providers = ["COGNITO"] // only use Cognito's own user pool as the identity provider not google/facebook

  callback_urls = ["https://example.com"]
  logout_urls   = ["https://www.example.com/about"]

}

resource "aws_cognito_user" "cognito_user" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username = var.cognito_username
  password = var.cognito_password
}
