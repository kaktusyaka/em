# frozen_string_literal: true

module InstagramService
  class Client
    include InstagramService::Endpoints::Accounts
    include InstagramService::Endpoints::Challenge
    include InstagramService::Endpoints::Users
    include InstagramService::Endpoints::Friendships
    include InstagramService::Endpoints::Feed
    include InstagramService::Endpoints::Media
    include InstagramService::Utils

    API_URL = 'https://i.instagram.com/api/v1/'

    USER_AGENT = InstagramService::Constants::USER_AGENT
    IG_SIG_KEY = InstagramService::Constants::IG_SIG_KEY
    IG_CAPABILITIES = InstagramService::Constants::IG_CAPABILITIES
    SIG_KEY_VERSION = InstagramService::Constants::SIG_KEY_VERSION
    APPLICATION_ID = InstagramService::Constants::APPLICATION_ID

    attr_accessor :account, :username, :password, :auto_patch, :drop_incompat_keys,
                  :api_url, :timeout, :on_login, :logger, :uuid, :device_id,
                  :session_id, :signature_key, :key_version, :ig_capabilities,
                  :application_id, :user_agent, :app_version, :android_release,
                  :android_version, :phone_manufacturer, :phone_device,
                  :phone_model, :phone_dpi, :phone_resolution, :phone_chipset,
                  :version_code, :ad_id, :csrftoken

    def initialize(account, kwargs = {})
      # param username: Login username
      # param password: Login password
      # param kwargs: See below
      # :Keyword Arguments:
      #   - **auto_patch**: Patch the api objects to match the public API. Default: False
      #   - **drop_incompat_key**: Remove api object keys that is not in the public API. Default: False
      #   - **timeout**: Timeout interval in seconds. Default: 15
      #   - **api_url**: Override the default api url base
      #   - **cookie**: Saved cookie string from a previous session
      #   - **settings**: A dict of settings from a previous session
      #   - **on_login**: Callback after successful login
      #   - **proxy**: Specify a proxy ex: 'http://127.0.0.1:8888' (ALPHA)
      #   - **proxy_handler**: Specify your own proxy handler

      self.username = account.username
      self.password = account.password
      self.account = account
      kwargs = account.client_settings
      self.auto_patch = kwargs.fetch('auto_patch', false)
      self.drop_incompat_keys = kwargs.fetch('drop_incompat_keys', false)
      self.api_url = kwargs.fetch('api_url', nil) || API_URL
      self.timeout = kwargs.fetch('timeout', 15)
      self.on_login = kwargs.fetch('on_login', nil)
      self.logger = Rails.logger

      user_settings = kwargs.fetch('settings', {})

      self.uuid =
        kwargs.fetch('guid', nil) || kwargs.fetch('uuid', nil) ||
        user_settings['uuid'] || generate_uuid(false)

      self.device_id =
        kwargs.fetch('device_id', nil) || user_settings['device_id'] ||
        generate_deviceid

      # application session ID
      self.session_id =
        kwargs.fetch('session_id', nil) || user_settings['session_id'] ||
        generate_uuid(false)
      self.signature_key =
        kwargs.fetch('signature_key', nil) || user_settings['signature_key'] ||
        IG_SIG_KEY
      self.key_version =
        kwargs.fetch('key_version', nil) || user_settings['key_version'] ||
        SIG_KEY_VERSION
      self.ig_capabilities =
        kwargs.fetch('ig_capabilities', nil) || user_settings['ig_capabilities'] ||
        IG_CAPABILITIES
      self.application_id =
        kwargs.fetch('application_id', nil) || user_settings['application_id'] ||
        APPLICATION_ID

      # to maintain backward compat for user_agent kwarg
      custom_ua = kwargs.fetch('user_agent', nil) || user_settings['user_agent']
      if custom_ua
        self.user_agent = custom_ua
      else
        self.app_version =
          kwargs.fetch('app_version', nil) || user_settings['app_version'] ||
          InstagramService::Constants::APP_VERSION
        self.android_release =
          kwargs.fetch('android_release', nil) || user_settings['android_release'] ||
          InstagramService::Constants::ANDROID_RELEASE
        self.android_version = (kwargs.fetch('android_version', nil) || user_settings['android_version'] ||
                                InstagramService::Constants::ANDROID_VERSION).to_i
        self.phone_manufacturer =
          kwargs.fetch('phone_manufacturer', nil) || user_settings['phone_manufacturer'] ||
          InstagramService::Constants::PHONE_MANUFACTURER
        self.phone_device = (
          kwargs.fetch('phone_device', nil) || user_settings['phone_device'] ||
          InstagramService::Constants::PHONE_DEVICE)
        self.phone_model = (
          kwargs.fetch('phone_model', nil) || user_settings['phone_model'] ||
          InstagramService::Constants::PHONE_MODEL)
        self.phone_dpi = (
          kwargs.fetch('phone_dpi', nil) || user_settings['phone_dpi'] ||
          InstagramService::Constants::PHONE_DPI)
        self.phone_resolution = (
          kwargs.fetch('phone_resolution', nil) || user_settings['phone_resolution'] ||
          InstagramService::Constants::PHONE_RESOLUTION)
        self.phone_chipset = (
          kwargs.fetch('phone_chipset', nil) || user_settings['phone_chipset'] ||
          InstagramService::Constants::PHONE_CHIPSET)
        self.version_code = (
          kwargs.fetch('version_code', nil) || user_settings['version_code'] ||
          InstagramService::Constants::VERSION_CODE)
      end

      self.ad_id =
        kwargs.fetch('ad_id', nil) || user_settings['ad_id'] || generate_adid

    end

    def parse_cookie(cookies)
      cookie_hash = {}
      ['ds_user', 'urlgen', 'is_starred_enabled', 'igfl', 'shbid', 'shbts', 'csrftoken', 'rur', 'mid', 'ds_user_id', 'sessionid'].each do |key|
        cookie = cookies.match(/\b#{key}.*\; /).to_s.split(';').first.to_s.split("#{key}=").last.to_s
        cookie_hash[key] = cookie
      end
      cookie_hash
    end

    def get_client_settings
      hash = {}
      %w[auto_patch timeout on_login uuid device_id session_id signature_key
        key_version ig_capabilities application_id app_version android_release
        android_version phone_manufacturer phone_device phone_model phone_dpi
        phone_resolution phone_chipset version_code ad_id].each do |key|
          hash[key] = send(key)
        end
      hash
    end

    private

    def authenticated_params
      { _csrftoken: csrftoken,
        _uuid: uuid,
        _uid: authenticated_user_id }
    end

    def authenticated_user_id
      # The current authenticated user id
      account.account_session['ds_user_id']
    end

    def generate_uuid(return_hex = false, seed = nil)
      # Generate uuid
      # param return_hex: Return in hex format
      # param seed: Seed value to generate a consistent uuid

      new_uuid =
        if seed
          Digest::MD5.hexdigest(seed).unpack('a8a4a4a4a12').join('-')
        else
          SecureRandom.uuid
        end

      return new_uuid unless return_hex

      new_uuid.delete('-')
    end

    def generate_deviceid(seed = nil)
      # Generate an android device ID
      # param seed: Seed value to generate a consistent device ID
      'android-' + generate_uuid(true, seed)[0..15]
    end

    def generate_adid(seed = nil)
      # Generate an Advertising ID based on the login username since
      # the Google Ad ID is a personally identifying but resettable ID.
      modified_seed = seed || authenticated_user_name || username
      if modified_seed
        # Do some trivial mangling of original seed
        modified_seed = Digest::SHA256.hexdigest(modified_seed)
      end

      generate_uuid(false, modified_seed)
    end

    def authenticated_user_name
      nil
    end

    def check_csrftoken(cookies)
      self.csrftoken = cookies['csrftoken']
    end

    def generate_signature(data)
      # Generates the signature for a data string
      # :param data: content to be signed
      OpenSSL::HMAC.hexdigest OpenSSL::Digest.new('sha256'), signature_key, data
    end

    def phone_id
      # Current phone ID. For use in certain functions.
      generate_uuid(false, device_id)
    end

    def radio_type
      # For use in certain endpoints
      'wifi-none'
    end

    def default_headers
      {
        'User-Agent': user_agent || USER_AGENT,
        'Connection': 'keep-alive',
        'Accept': '*/*',
        'Accept-Language': 'en',
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        # 'Accept-Encoding': 'gzip, deflate, sdch',
        'X-IG-Capabilities': ig_capabilities,
        'X-IG-Connection-Type': 'WIFI',
        'X-IG-Connection-Speed': "-1kbps",
        'X-IG-App-ID': application_id,
        'X-IG-Bandwidth-Speed-KBPS': '-1.000',
        'X-IG-Bandwidth-TotalBytes-B': '0',
        'X-IG-Bandwidth-TotalTime-MS': '0',
        'X-FB-HTTP-Engine': InstagramService::Constants::FB_HTTP_ENGINE
      }
    end

    def call_api(endpoint, method = 'GET', params = {}, args = { return_response: false, unsigned: false, query: { } } )
      # Calls the private api.
      # :param endpoint: endpoint path that should end with '/', example 'discover/explore/'
      # :param params: POST parameters
      # :param query: GET url query parameters
      # :param return_response: return the response instead of the parsed json object
      # :param unsigned: use post params as-is without signing
      url = format('%{url}%{endpoint}', url: API_URL, endpoint: endpoint)

      headers = default_headers

      if params.any?
        headers['Content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        headers['Cookie'] = set_cookie(account.account_session).to_cookie_string

        if args[:unsigned] == false
          json_params = JSON.dump(params)
          hash_sig = generate_signature(json_params)
          params[:ig_sig_key_version] = key_version
          params[:signed_body] = hash_sig + '.' + json_params
        end
      end

      begin
        if method == 'GET'
          response = ProxyHttp.get(url, body: params, query: args[:query], headers: headers)
        elsif method == 'POST'
          response = ProxyHttp.post(url, body: params, headers: headers, query: args[:query])
        end
      # catch connection issues
      rescue HTTParty::Error => e

      end

      InstagramService::Errors::Handler.process(self, response) unless response.success?

      return response if args[:return_response]

      parsed_response = response.parsed_response

      if parsed_response['message'] == 'login_required'
        raise InstagramService::Errors::ClientLoginRequired.new(self, code: response.code, error_response: response), 'login_required'
      end

      if parsed_response['provider_url'] && parsed_response['status'] != 'ok'
        raise InstagramService::Errors::Client.new(self, code: response.code, error_response: response), 'Unknown error'
      end

      parsed_response
    end

    def set_cookie(cookies)
      cookie_hash = HTTParty::CookieHash.new
      cookies.each do |key, value|
        next if value.blank?
        cookie_hash.add_cookies(key => value)
      end
      cookie_hash
    end
  end
end
