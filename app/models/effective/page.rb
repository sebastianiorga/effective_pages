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
  end

end




