module Effective
  class Page < ActiveRecord::Base
    belongs_to :parent, class_name: 'Effective::Page'
    has_many :children, class_name: 'Effective::Page', foreign_key: :parent_id

    default_scope -> { eager_load :parent }
    has_attached_file :thumbnail,
                    path: ':rails_root/public/public_storage/:rails_env/pages/:id/:style/:basename.:extension',
                    url: '/public_storage/:rails_env/pages/:id/:style/:basename.:extension',
                    styles: {
                      small: '176x86#'
                    }
    validates_attachment_content_type :thumbnail,
                                    content_type: /\A(image\/.*)\Z/
    attr_accessor :delete_thumbnail
    before_validation { thumbnail.clear if delete_thumbnail == '1' }

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
    scope :sort_ordered, -> { order :sort_order }
    scope :exclude_chunks, -> { where('pages.just_a_chunk = false OR pages.just_a_chunk IS NULL') }

    def sort_ordered_children
      children.sort_ordered
    end

    def contextualized_slug
      return override_url if override_url.present?

      return "#{slug}" if parent.blank? || parent == self

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

      return "#{slug_was}" if parent.blank? || parent == self

      "#{parent.contextualized_slug}#{url_delimiter}#{slug_was}"
    end

    def self.regular_find?(args)
      args.is_a?(Array) || args.to_i > 0
    end

    def to_s
      title
    end

    def css
      regions.find_by(title: :css).try :content
    end

    def self_or_parent_with_css
      return self if css.present?

      return if parent.blank? || parent == self

      parent.self_or_parent_with_css
    end
  end
end
