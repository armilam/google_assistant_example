# This controller "implements" oauth authorization.
# You can also store scopes with the access tokens.
# Any requests that want to use a granted acces_token
# will do so by adding the following header to their requests:
# Authorization: Bearer ACCESS_TOKEN
# For Google Actions SDK requests, the access_token will
# come through as part of the user object in the request.

class OauthController < ApplicationController

  def authorize
    puts "\n\n\n\n\n\nAUTHORIZE"

    errors = []

    # verify client_id matches my client id
    errors << "I don't recognize client id: #{params[:client_id]}" unless valid_client_id?

    # verify redirect_uri matches the correct redirect uri for google
    errors << "I don't recognize redirect uri: #{params[:redirect_uri]}" unless valid_redirect_uri?

    # verify response_type is code
    errors << "I don't recognize response type: #{params[:response_type]}" unless params[:response_type] == "code"

    if errors.any?
      render json: { errors: errors }, status: 401
    else
      # is user signed in already?
        # if not, ask the user to sign in

      # generate an auth code for this user
      # code should have an expiration in, say, 10 minutes
      # code should be associated with the client id and the user
      # also, store requested scopes if any, from params[:scope]
      # store this code somewhere
      auth_code = "this_is_a_random_code"

      # redirect to redirect_uri?code=AUTHORIZATION_CODE&state=STATE_STRING
      redirect_to "#{params[:redirect_uri]}?code=#{auth_code}&state=#{params[:state]}"
    end
  end

  def token
    puts "\n\n\n\n\n\nTOKEN"

    errors = []

    # verify client_id matches my client id
    errors << "I don't recognize client id: #{params[:client_id]}" unless valid_client_id?

    # verify client_secret matches my client secret
    errors << "I don't recognize client secret: #{params[:client_secret]}" unless valid_client_secret?

    if errors.any?
      render json: { errors: errors }, status: 401
    else
      case params[:grant_type]
      when "authorization_code"
        authorization_code(params[:code])
      when "refresh_token"
        refresh_token(params[:token])
      else
        render json: { errors: ["I don't recognize grant type: #{params[:grant_type]}"] }, status: 404
      end
    end
  end

  private

  def valid_client_id?
    params[:client_id] == ENV["GOOGLE_OAUTH_CLIENT_ID"]
  end

  def valid_client_secret?
    params[:client_secret] == ENV["GOOGLE_OAUTH_CLIENT_SECRET"]
  end

  def valid_redirect_uri?
    params[:redirect_uri] == "https://oauth-redirect.googleusercontent.com/r/#{ENV["GOOGLE_APP_ID"]}"
  end

  def authorization_code(code)
    # validate the authorization code in the place i'm storing auth codes
    raise "I don't recognize authorization code: #{code}" unless code == "this_is_a_random_code"

    # verify auth code is not expired
    raise "Code is expired" unless true

    # generate a refresh and access token and store them, along with an expiration for the access token (typically in an hour)
    # also, store them
    new_access_token = "this_is_definitely_an_access_token_2"
    new_refresh_token = "this_is_totally_a_refresh_token"

    # return some json info
    render json: {
      token_type: "bearer",
      access_token: new_access_token,
      refresh_token: new_refresh_token
    }
  end

  def refresh_token(token)
    # validate the refresh token exists along with the client_id in the place i'm storing them
    raise "I don't recognize refresh token: #{token}" unless token == "this_is_totally_a_refresh_token"

    # generate an access token, along with an expiration (typically in an hour)
    # also, store it
    access_token = "this_is_definitely_an_access_token_2"

    render json: {
      token_type: "bearer",
      access_token: new_access_token
    }
  end
end
