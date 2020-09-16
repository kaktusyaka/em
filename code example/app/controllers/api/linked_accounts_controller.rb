# frozen_string_literal: true

class Api::LinkedAccountsController < Api::ApiController
  inherit_resources

  actions :index, :create

  def index
    render json:
      LinkedAccountSerializer.new(collection).serializable_hash
  end

  def create
    create! do |success|
      success.json do
        render json: LinkedAccountSerializer.new(resource).serializable_hash
      end
    end
  end

  private

  def begin_of_association_chain
    current_user
  end

  def build_resource
    super.tap do |attr|
      attr.user = current_user
    end
  end

  def permitted_params
    { linked_account: params.fetch(:linked_account, {}).permit(
      :username, :password) }
  end
end
