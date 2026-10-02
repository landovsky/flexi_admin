# frozen_string_literal: true

require 'rails_helper'

# Admin users work through long lists and kept re-picking the same page size on
# every visit, because `fa_per_page` only ever lived in the URL.
RSpec.describe 'Per-page memory', type: :request do
  before { create_list(:user, 3) }

  def selected_per_page
    Nokogiri::HTML(response.body).at_css('select[name="per_page"] option[selected]')&.text
  end

  context 'when a user picks a page size for a section' do
    it 'serves that size again on a later visit that names no page size' do
      get '/admin/users', params: { fa_per_page: 24 }
      expect(selected_per_page).to eq('24')

      get '/admin/users'

      expect(selected_per_page).to eq('24')
    end

    it 'still honours an explicit page size that disagrees with what was remembered' do
      get '/admin/users', params: { fa_per_page: 24 }

      get '/admin/users', params: { fa_per_page: 48 }

      expect(selected_per_page).to eq('48')
    end

    it 'remembers the new choice once the user changes their mind' do
      get '/admin/users', params: { fa_per_page: 24 }
      get '/admin/users', params: { fa_per_page: 48 }

      get '/admin/users'

      expect(selected_per_page).to eq('48')
    end
  end

  context 'when nothing has ever been picked' do
    it 'falls back to the configured default rather than an empty page size' do
      get '/admin/users'

      expect(selected_per_page).to eq(FlexiAdmin::Config.configuration.paginate_per.to_s)
    end
  end

  context 'when the remembered value is one the app does not offer' do
    # The cookie is user-writable, so it must never widen a query beyond the
    # sizes the app itself offers.
    it 'ignores it and falls back to the default' do
      cookies['fa_per_page_admin_users'] = '100000'

      get '/admin/users'

      expect(selected_per_page).to eq(FlexiAdmin::Config.configuration.paginate_per.to_s)
    end
  end
end
