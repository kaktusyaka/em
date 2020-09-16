# frozen_string_literal: true
require 'action_text/engine'

ActiveAdmin.register Articles::PiarForYou, as: 'PiarForYou' do
  menu parent: 'Articles', label: 'PiarForYou'

  permit_params :title, :description

  index do
    id_column
    column :title
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :title
      f.input :description, as: :rich_text
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description do |p|
        p.description.to_s
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
