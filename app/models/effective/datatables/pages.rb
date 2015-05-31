if defined?(EffectiveDatatables)
  module Effective
    module Datatables
      class Pages < Effective::Datatable
        default_order :title, :asc

        table_column :id, :visible => false

        table_column :title
        table_column :slug
        table_column :draft
        table_column :override_url
        array_column :parent, filter: { type: :text } do |page|
          next if page.parent.blank?

          link_to page.parent, "/admin/pages/#{page.parent.id}/edit"
        end

        table_column :actions, :sortable => false, :filter => false, :partial => '/admin/pages/actions'

        def collection
          Effective::Page.all
        end

        def search_column(collection, table_column, search_term)
          if table_column[:name] == 'parent'
            collection.where 'LOWER(parents_pages.title) LIKE LOWER(?)', "%#{search_term}%"
          else
            super
          end
        end
      end
    end
  end
end
