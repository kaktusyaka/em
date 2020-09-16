class OrderDecorator < ApplicationDecorator
  delegate_all

  def status_css_class
    { pending: 'label-warning',
      processing: 'label-info',
      in_progress: 'label-primary',
      completed: 'label-green',
      error: 'label-alert',
      canceled: 'label-secondary',
      partially_completed: 'label-yellow' }[model.aasm_state.to_sym]
  end
end
