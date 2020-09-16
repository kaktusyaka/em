# frozen_string_literal: true

ActiveAdmin.register Service do
  permit_params :service_category_id, :code, :name, :description, :min_quantity,
                :price_for_thousand_original, :price_for_thousand,
                :max_quantity, :active, :allow_timer, :allow_comments,
                :timer_interval_label, :timer_likes_label, :resource_label,
                :features, :link_url_label, :url_type

  index do
    id_column
    column :service_category do |e|
      e.service_category.name
    end
    column :active
    column :name
    column :code
    column :price_for_thousand_original do |e|
      number_to_currency(e.price_for_thousand_original)
    end
    column :price_for_thousand do |e|
      number_to_currency(e.price_for_thousand)
    end
    column :min_quantity
    column :max_quantity
    column :allow_timer
    column :allow_comments
    actions
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :service_category_id, as: :select, collection: ServiceCategory.all
      f.input :active
      f.input :code
      f.input :name
      f.input :url_type, collection: %w[p tv profile]
      f.input :price_for_thousand_original, min: 0
      f.input :price_for_thousand, min: 0
      f.input :min_quantity
      f.input :max_quantity
      f.input :allow_timer
      f.input :timer_interval_label
      f.input :timer_likes_label
      f.input :resource_label
      f.input :link_url_label
      f.input :allow_comments
      f.input :features, as: :tags, collection: f.object.features.to_s.split(',')
      f.input :description, as: :rich_text
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :service_category do |e|
        e.service_category.name
      end
      row :active
      row :name
      row :url_type
      row :code
      row :price_for_thousand_original do |e|
        number_to_currency(e.price_for_thousand_original)
      end
      row :price_for_thousand do |e|
        number_to_currency(e.price_for_thousand)
      end
      row :min_quantity
      row :max_quantity
      row :allow_timer
      row :allow_comments
      row :timer_likes_label
      row :timer_interval_label
      row :link_url_label
      row :resource_label
      row :features
      row :description do |p|
        p.description.to_s
      end
    end
    active_admin_comments
  end
end
