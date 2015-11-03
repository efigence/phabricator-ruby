require 'phabricator/conduit_client'

module Phabricator
  class Repository
    @@cached_repos = {}

    attr_reader :phid
    attr_accessor :name

    def self.populate_all
      response = client.request(:post, 'repository.query')

      response['result'].each do |data|
        repo = Repository.new(data)
        @@cached_repos[repo.name] = repo
      end

    end

    def self.find_by_name(name)
      # Re-populate if we couldn't find it in the cache (this applies to
      # if the cache is empty as well).
      populate_all unless @@cached_repos[name]

      @@cached_repos[name]
    end

    def self.create(name, attrs={})
      response = client.request(:post, 'repository.create', {
        name: name }.merge(attrs))
      data = response['result']

      self.new(data)
    end

    def initialize(attributes)
      @phid = attributes['phid']
      @name = attributes['name']
    end

    def self.list_repos()
      populate_all
      return @@cached_repos
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
