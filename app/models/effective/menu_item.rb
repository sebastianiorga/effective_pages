module Effective
  class MenuItem < ActiveRecord::Base
    belongs_to :menu, :inverse_of => :menu_items, :touch => true
    belongs_to :menuable, :polymorphic => true # Optionaly belong to an object

    self.table_name = EffectivePages.menu_items_table_name.to_s

    structure do
      title           :string
      url             :string
      classes         :string
      new_window      :boolean, :default => false, :validates => [:boolean]

      lft             :integer, :validates => [:presence], :index => true
      rgt             :integer, :validates => [:presence]
    end

    default_scope -> { includes(:menuable).order('lft ASC') }

    # before_validation do
    #   if menuable.present?
    #     self.title = nil if menuable.menu_title == self[:title]
    #     self.url = nil if menuable.menu_url == self[:url]
    #   end
    #   true
    # end

    # def title
    #   self[:title] || menuable.menu_title rescue nil
    # end

    # def url
    #   self[:url] || menuable.menu_url rescue nil
    # end
  end
end
