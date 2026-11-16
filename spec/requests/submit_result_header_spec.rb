# frozen_string_literal: true

require 'rails_helper'

# The submit button (submit_button_controller.js) shows ✓ / ✕ after a save. The gem answers a
# failed validation with 200 + the re-rendered form, so the browser cannot tell success from
# failure by status; the X-FlexiAdmin-Submit-Result header carries the verdict instead.
RSpec.describe 'Submit result header', type: :request do
  let(:header) { FlexiAdmin::Controllers::ResourcesController::SUBMIT_RESULT_HEADER }
  let(:turbo) { { 'Accept' => 'text/vnd.turbo-stream.html' } }
  let(:user) { create(:user) }

  context 'saving an edit form' do
    it 'reports success when the record saved, so the button shows ✓' do
      patch "/admin/users/#{user.id}", params: { user: { full_name: 'Nové jméno' } }, headers: turbo

      expect(response.headers[header]).to eq('success')
    end

    it 'reports an error on a validation failure even though the status is 200, so the button shows ✕' do
      patch "/admin/users/#{user.id}", params: { user: { email: '' } }, headers: turbo

      expect(response).to have_http_status(:ok)
      expect(response.headers[header]).to eq('error')
    end
  end

  context 'running a bulk action from a modal' do
    it 'reports success when the processor says so' do
      post '/admin/users/bulk_action', headers: turbo, params: {
        processor: 'admin-user-bulk_action-export_modal_component', ids: [user.id].to_json
      }

      expect(response.headers[header]).to eq('success')
    end

    it 'reports an error when the processor result is :error, which still answers 200 with a toast' do
      allow_any_instance_of(Admin::User::BulkAction::ExportModalComponent::Processor)
        .to receive(:perform)
        .and_return(Admin::User::BulkAction::ExportModalComponent::Processor::Result.new(result: :error, message: 'Export selhal'))

      post '/admin/users/bulk_action', headers: turbo, params: {
        processor: 'admin-user-bulk_action-export_modal_component', ids: [user.id].to_json
      }

      expect(response).to have_http_status(:ok)
      expect(response.headers[header]).to eq('error')
    end
  end

  context 'opening the bulk-action modal' do
    def open_modal
      get '/flexi_admin/modals', headers: turbo,
                                 params: { kind: 'admin-user-bulk_action-export_modal_component', fa_scope: 'users' }
    end

    it 'wires "Spustit" to the submit button, because it sits outside the form and Turbo cannot lock it' do
      open_modal

      expect(response.body).to include('data-controller="submit-button"')
    end

    it 'leaves "Spustit" plain when a host turned the feature off' do
      FlexiAdmin::Config.configuration.submit_button_states = false
      open_modal

      expect(response.body).not_to include('data-controller="submit-button"')
    ensure
      FlexiAdmin::Config.configuration.submit_button_states = true
    end
  end
end
