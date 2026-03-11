# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reload_frame after bulk_action', type: :request do
  let!(:users) { create_list(:user, 3) }
  let(:user_ids) { users.map(&:id).to_json }
  let(:export_processor) { 'admin-user-bulk_action-export_modal_component' }
  let(:reset_processor) { 'admin-user-bulk_action-reset_modal_component' }

  def bulk_action_params(processor: export_processor, **overrides)
    {
      processor: processor,
      ids: user_ids
    }.merge(overrides)
  end

  describe 'turbo stream response' do
    it 'returns turbo_stream content type' do
      post '/admin/users/bulk_action', params: bulk_action_params

      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    end

    it 'includes reload_frame script appended to system' do
      post '/admin/users/bulk_action', params: bulk_action_params

      expect(response.body).to include('action="append"')
      expect(response.body).to include('target="system"')
      expect(response.body).to include('getElementById')
    end

    it 'includes toast append action' do
      post '/admin/users/bulk_action', params: bulk_action_params

      expect(response.body).to include('target="toasts"')
    end
  end

  describe 'frame scope resolution' do
    context 'without fa_scope or fa_reload_frame params' do
      it 'falls back to resource_class.model_name.plural' do
        post '/admin/users/bulk_action', params: bulk_action_params

        expect(response.body).to include("getElementById('users')")
      end
    end

    context 'with fa_scope param' do
      it 'uses fa_scope as the frame target' do
        post '/admin/users/bulk_action',
             params: bulk_action_params(fa_scope: 'custom_users_scope')

        expect(response.body).to include("getElementById('custom_users_scope')")
      end
    end

    context 'with fa_reload_frame param' do
      it 'uses fa_reload_frame as the frame target' do
        post '/admin/users/bulk_action',
             params: bulk_action_params(fa_reload_frame: 'my_custom_frame')

        expect(response.body).to include("getElementById('my_custom_frame')")
      end

      it 'takes precedence over fa_scope' do
        post '/admin/users/bulk_action',
             params: bulk_action_params(fa_scope: 'should_be_ignored', fa_reload_frame: 'takes_priority')

        expect(response.body).to include("getElementById('takes_priority')")
        expect(response.body).not_to include("getElementById('should_be_ignored')")
      end
    end
  end

  describe 'fallback to page reload' do
    it 'includes window.location.reload() fallback when frame not found' do
      post '/admin/users/bulk_action', params: bulk_action_params

      expect(response.body).to include('window.location.reload()')
    end
  end

  describe 'modal cleanup' do
    it 'includes modal dismiss logic' do
      post '/admin/users/bulk_action', params: bulk_action_params

      expect(response.body).to include('.modal.show')
      expect(response.body).to include('.modal-backdrop')
      expect(response.body).to include('modal-open')
    end
  end

  describe 'referrer as frame src' do
    it 'uses request referrer as the frame reload URL' do
      post '/admin/users/bulk_action',
           params: bulk_action_params,
           headers: { 'HTTP_REFERER' => 'http://localhost:3000/admin/users/1' }

      expect(response.body).to include("src = 'http://localhost:3000/admin/users/1'")
    end
  end

  describe 'explicit full page reload' do
    context 'when processor returns reload: :page' do
      it 'uses reload_page instead of reload_frame' do
        post '/admin/users/bulk_action', params: bulk_action_params(processor: reset_processor)

        expect(response.body).to include('window.location.reload()')
        expect(response.body).not_to include('getElementById')
      end
    end

    context 'when fa_reload=page param is passed' do
      it 'uses reload_page instead of reload_frame' do
        post '/admin/users/bulk_action', params: bulk_action_params(fa_reload: 'page')

        expect(response.body).to include('window.location.reload()')
        expect(response.body).not_to include('getElementById')
      end

      it 'overrides fa_reload_frame param' do
        post '/admin/users/bulk_action',
             params: bulk_action_params(fa_reload: 'page', fa_reload_frame: 'some_frame')

        expect(response.body).to include('window.location.reload()')
        expect(response.body).not_to include('getElementById')
      end
    end
  end
end
