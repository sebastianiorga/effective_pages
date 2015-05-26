module Effective
  class Page < ActiveRecord::Base
    belongs_to :parent, class_name: 'Effective::Page'
    has_many :children, class_name: 'Effective::Page', foreign_key: :parent_id
    acts_as_sluggable
    acts_as_role_restricted
    acts_as_regionable

    has_many :menu_items, :as => :menuable, :dependent => :destroy

    self.table_name = EffectivePages.pages_table_name.to_s

    structure do
      title             :string, :validates => [:presence, :length => {:maximum => 255}]
      meta_description  :string, :validates => [:presence, :length => {:maximum => 255}]

      draft             :boolean, :default => false

      layout            :string, :default => 'application', :validates => [:presence]
      template          :string, :validates => [:presence]

      slug              :string
      roles_mask        :integer, :default => 0

      timestamps
    end

    scope :drafts, -> { where(:draft => true) }
    scope :published, -> { where(:draft => false) }

    def contextualized_slug
      return override_url if override_url.present?

      return "#{url_delimiter}#{slug}" if parent.blank? || parent == self

      "#{parent.contextualized_slug}#{url_delimiter}#{slug}"
    end

    def url_delimiter
      return '#' if just_a_chunk_was

      '/'
    end

    def self.customized_find(arg)
      return find(arg) if regular_find?(arg)

      clean_arg = arg.split('#')[0].to_s.gsub(/^\/*/, '').gsub(/\/*$/, '')

      overriden = find_by override_url: clean_arg

      return overriden if overriden.present?

      find_by_contextualized_slug(clean_arg)
    end

    def self.find_by_contextualized_slug(arg)
      splits = arg.split('/').select(&:present?)
      root = find_by! slug: splits[0]
      rest = splits[1..-1]

      return root if rest.empty?

      rest.reduce(root) do |a, e|
        a.children.find_by! slug: e
      end
    end

    def to_param
      slug.present? ? contextualized_slug_was : super
    end

    def contextualized_slug_was
      return override_url_was if override_url_was.present?

      return "#{url_delimiter}#{slug_was}" if parent.blank? || parent == self

      "#{parent.contextualized_slug}#{url_delimiter}#{slug_was}"
    end

    def self.regular_find?(args)
      args.is_a?(Array) || args.to_i > 0
    end

    def to_s
      title
    end
  end
end
