# frozen_string_literal: true

ActiveAdmin.register Support::Ticket do
  permit_params :subject, :description, files: []

  member_action :comment, method: :post do
    resource.comments.create(support_comment_params)
    redirect_to admin_support_ticket_url(resource)
  end

  member_action :mark_as_closed, method: :get do
    resource.close!
    redirect_to admin_support_ticket_url(resource), notice: 'Ticket has been marked as closed'
  end

  controller do
    def support_comment_params
      params.require(:support_comment).permit(:description, files: [])
    end
  end

  action_item :mark_as_closed, only: :show, if: proc { resource.may_close? } do
    link_to 'Mark as Closed', mark_as_closed_admin_support_ticket_path(resource)
  end

  index do
    column :id
    column :subject
    state_column :aasm_state
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      state_row :aasm_state
      row :subject
      row :description do |e|
        e.description.to_s
      end
      row :created_at
      row :updated_at
      row :files do
        table_for resource.files do
          column do |f|
            link_to f.filename.to_s, url_for(f), target: '_blank'
          end
        end
      end
    end

    panel 'New Comment' do
      active_admin_form_for(resource.comments.new, url: comment_admin_support_ticket_url(resource)) do |f|
        f.inputs do
          f.input :description, as: :rich_text
          f.input :files, as: :file, input_html: { direct_upload: true, multiple: true }
        end
        f.actions do
          f.action :submit, label: I18n.t('active_admin.comments.add')
        end
      end
    end

    panel 'Comments' do
      render 'comments', { comments: resource.comments.asc }
    end
  end
end
