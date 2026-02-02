# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ResourcesController', type: :request do
  let(:user) { create(:user) }

  describe 'GET /admin/users' do
    it 'returns successful response' do
      get '/admin/users'
      expect(response).to have_http_status(:success)
    end

    it 'renders index page with resources' do
      users = create_list(:user, 5)
      get '/admin/users'

      expect(response.body).to include(users.first.full_name)
    end

    it 'applies search filter' do
      matching_user = create(:user, full_name: 'Search Match')
      create(:user, full_name: 'No Match')

      get '/admin/users', params: { search: 'Search Match' }

      expect(response.body).to include('Search Match')
    end

    it 'applies sorting' do
      get '/admin/users', params: { sort_by: 'full_name', sort_direction: 'asc' }

      expect(response).to have_http_status(:success)
    end

    it 'paginates results' do
      create_list(:user, 50)

      get '/admin/users', params: { page: 2, per_page: 16 }

      expect(response).to have_http_status(:success)
      # Should show page 2 users
    end
  end

  describe 'GET /admin/users/:id' do
    it 'shows user details' do
      get "/admin/users/#{user.id}"

      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.full_name)
      expect(response.body).to include(user.email)
    end

    it 'returns 404 for non-existent user' do
      expect {
        get '/admin/users/99999'
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST /admin/users' do
    it 'creates new user with valid params' do
      user_params = {
        user: {
          full_name: 'New User',
          email: 'new@example.com',
          role: 'user'
        }
      }

      expect {
        post '/admin/users', params: user_params
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:redirect)
    end

    it 'renders turbo_stream response when requested' do
      user_params = {
        user: {
          full_name: 'New User',
          email: 'new@example.com'
        }
      }

      post '/admin/users', params: user_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response.content_type).to include('turbo-stream')
    end
  end

  describe 'PATCH /admin/users/:id' do
    it 'updates user with valid params' do
      patch "/admin/users/#{user.id}", params: {
        user: { full_name: 'Updated Name' }
      }

      user.reload
      expect(user.full_name).to eq('Updated Name')
      expect(response).to have_http_status(:redirect)
    end

    it 'renders errors for invalid params' do
      patch "/admin/users/#{user.id}", params: {
        user: { email: '' }  # Invalid - email required
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /admin/users/:id' do
    it 'destroys user' do
      user_to_delete = create(:user)

      expect {
        delete "/admin/users/#{user_to_delete.id}"
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'Bulk Actions' do
    it 'processes bulk delete action' do
      users_to_delete = create_list(:user, 3)
      user_ids = users_to_delete.map(&:id).to_json

      expect {
        post '/admin/users/bulk_action', params: {
          action: 'delete',
          ids: user_ids
        }
      }.to change(User, :count).by(-3)
    end
  end

  describe 'Parent/Child Relationships' do
    it 'loads nested resource with parent context' do
      comment = create(:comment, user: user)

      get "/admin/users/#{user.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:success)
      # Should include parent breadcrumb
    end

    it 'propagates parent via GlobalID' do
      get "/admin/users/#{user.id}/comments/new"

      expect(response.body).to include(user.to_global_id.to_s)
    end
  end
end
