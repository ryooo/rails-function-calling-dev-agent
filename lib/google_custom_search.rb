class GoogleCustomSearch
  def search(query, args = {})
    service.list_cses(cx: ENV['GOOGLE_CUSTOM_SEARCH_CSE_ID'], q: query, **args)
  end

  def service
    @service ||= begin
      service = Google::Apis::CustomsearchV1::CustomSearchAPIService.new
      authorizer = make_authorizer
      authorizer.fetch_access_token!
      service.authorization = authorizer
      service
    end
  end

  def make_authorizer
    sa_key = ENV.fetch("GOOGLE_SA_PRIVATE_KEY", nil)
    key = ::OpenSSL::PKey::RSA.new(sa_key)
    cred = ::Signet::OAuth2::Client.new(
      token_credential_uri: "https://oauth2.googleapis.com/token",
      audience: "https://oauth2.googleapis.com/token",
      scope: %w[
        https://www.googleapis.com/auth/cse
      ],
      issuer: ENV.fetch("GOOGLE_SA_CLIENT_EMAIL"),
      signing_key: key
    )
    cred.configure_connection({})
  end
end
