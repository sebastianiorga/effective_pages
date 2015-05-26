if defined?(EffectiveDatatables)
  module Effective
    module Datatables
      class Pages < Effective::Datatable
        default_order :title, :asc
        default_entries :all

        table_column :id, :visible => false

        table_column :title
        table_column :slug
        table_column :draft
        table_column :override_url
        table_column :parent do |page|
          next if page.parent.blank?

          link_to page.parent, "/admin/pages#{page.parent.contextualized_slug}"
        end

        table_column :actions, :sortable => false, :filter => false, :partial => '/admin/pages/actions'

        def collection
          Effective::Page.all
        end
      end
    end
  end
end
