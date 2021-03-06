require "gemstash"

module Gemstash
  module DB
    # Sequel model for versions table.
    class Version < Sequel::Model
      def deindex
        update(indexed: false)
      end

      def reindex
        update(indexed: true)
      end

      def self.find_by_spec(gem_id, spec)
        self[rubygem_id: gem_id,
             number: spec.version.to_s,
             platform: spec.platform]
      end

      def self.find_by_full_name(full_name)
        result = self[full_name: full_name]
        return result if result
        # Try again with the default platform, in case it is implied
        self[full_name: "#{full_name}-ruby"]
      end

      def self.insert_by_spec(gem_id, spec)
        gem_name = Gemstash::DB::Rubygem[gem_id].name
        new(rubygem_id: gem_id,
            number: spec.version.to_s,
            platform: spec.platform,
            full_name: "#{gem_name}-#{spec.version}-#{spec.platform}",
            storage_id: spec.full_name,
            indexed: true).tap(&:save).id
      end
    end
  end
end
