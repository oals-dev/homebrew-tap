require "download_strategy"
require 'yaml'

# GitHubPrivateRepositoryReleaseDownloadStrategy downloads tarballs from GitHub
# Release assets. To use it, add `:using => :github_private_release` to the URL section
# of your formula. This download strategy uses GitHub access tokens (in the
# environment variables HOMEBREW_GITHUB_API_TOKEN) to sign the request.
class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
    @url = download_url
  end

  def download_url
    "https://#{@github_token}@api.#{@hostname}/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  
  private
  def parse_url_pattern
    url_pattern = %r{https://([^/]+)/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Release."
    end

    _, @hostname, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def get_github_token_for_host(hostname)    
    config_path = File.join(Dir.home, ".config/gh/hosts.yml")
    return nil unless File.exist?(config_path)
    
    config = YAML.load_file(config_path)
    return nil unless config&.key?(hostname)
  
    token = config[hostname]["oauth_token"]
    token
  end

  def set_github_token
    @github_token = get_github_token_for_host(@hostname) || ENV["HOMEBREW_GITHUB_API_TOKEN"]
    unless @github_token
      raise CurlDownloadStrategyError, "Github CLI is not configured and, environmental variable HOMEBREW_GITHUB_API_TOKEN is not defined."
    end

    validate_github_repository_access!
  end

  def validate_github_repository_access!
    # Test access to the repository
    GitHub.repository(@owner, @repo)
  rescue GitHub::API::HTTPNotFoundError
    # We only handle HTTPNotFoundError here,
    # because AuthenticationFailedError is handled within util/github.
    message = <<~EOS
      HOMEBREW_GITHUB_API_TOKEN can not access the repository: #{@owner}/#{@repo}
      This token may not have permission to access the repository or the URL of formula may be incorrect.
    EOS
    raise CurlDownloadStrategyError, message
  end

  def _fetch(url:, resolved_url:, timeout:)
    # HTTP request header `Accept: application/octet-stream` is required.
    # Without this, the GitHub API will respond with metadata, not binary.
    curl_download download_url, "--header", "Accept: application/octet-stream", to: temporary_path, timeout: timeout
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release_metadata = fetch_release_metadata
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    raise CurlDownloadStrategyError, "Asset file not found." if assets.empty?

    assets.first["id"]
  end

  def fetch_release_metadata
    release_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}"
    GitHub::API.open_rest(release_url)
  end
end
