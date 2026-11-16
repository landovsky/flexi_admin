# frozen_string_literal: true

require 'rails_helper'

# A failed create re-renders the new form so the user can fix it. Its Cancel button used to ask
# for the edit path of the record, which an unsaved record does not have, so the re-render raised
# UrlGenerationError and the user got a 500 instead of the validation errors (hriste #3y2y).
RSpec.describe 'New form after a failed validation', type: :request do
  let(:turbo) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

  it 're-renders the form with the error instead of crashing on Cancel' do
    post '/admin/users', params: { user: { full_name: 'Jan Novák', email: '' } }, headers: turbo

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Jan Novák')
  end

  it 'points Cancel back at the user list, since there is no saved record to return to' do
    post '/admin/users', params: { user: { full_name: 'Jan Novák', email: '' } }, headers: turbo

    expect(response.body).to match(%r{<a[^>]+href="/admin/users"[^>]*>Zrušit</a>})
  end

  it 'does not create the record, so the redraw really is the failure path' do
    expect do
      post '/admin/users', params: { user: { full_name: 'Jan Novák', email: '' } }, headers: turbo
    end.not_to change(User, :count)
  end
end
