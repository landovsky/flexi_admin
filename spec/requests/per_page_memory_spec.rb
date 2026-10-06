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
      cookies['fa_per_page_users'] = '100000'

      get '/admin/users'

      expect(selected_per_page).to eq(FlexiAdmin::Config.configuration.paginate_per.to_s)
    end
  end

  context 'when the size is picked from the selector inside the list frame' do
    # The selector and the grid/list switch request the list with `fa_scope`,
    # while a reload of the page does not. Both must hit the same memory, or
    # the choice silently lands under a key no later visit ever reads.
    it 'serves that size again when the page is reloaded without a scope' do
      get '/admin/users', params: { fa_scope: 'users', fa_view: 'list', fa_per_page: 24 }

      get '/admin/users'

      expect(selected_per_page).to eq('24')
    end
  end

  context 'when the user pages through a list' do
    it 'names the scope in the page links, so a size picked later is remembered under it' do
      create_list(:user, 30)

      get '/admin/users'

      next_link = Nokogiri::HTML(response.body).css('.pagination a').map { |a| a['href'] }.find { |h| h.include?('fa_page=2') }
      expect(next_link).to include('fa_scope=users')
    end
  end
end

# A list embedded in another resource's detail page is paginated by the host
# page with the default size before the list component renders, so the
# controller-side memory alone never reaches it.
RSpec.describe 'Per-page memory for a list embedded in a detail page', type: :request do
  before { create_list(:user, 30) }

  def rendered_rows
    Nokogiri::HTML(response.body).css('.row.border-top').size
  end

  def selected_per_page
    Nokogiri::HTML(response.body).at_css('select[name="per_page"] option[selected]')&.text
  end

  context 'when the user picked a size for that list from its selector' do
    before { get '/admin/users', params: { fa_scope: 'users', fa_per_page: 24 } }

    it 'shows that many rows again when the detail page is reloaded' do
      get '/admin/test/embedded_list'

      expect(rendered_rows).to eq(24)
      expect(selected_per_page).to eq('24')
    end

    it 'leaves alone a host page that chose its own size, e.g. a picker listing everything' do
      get '/admin/test/embedded_list', params: { host_per_page: 30 }

      expect(rendered_rows).to eq(30)
    end
  end

  context 'when the remembered size is not one the app offers' do
    it 'keeps the default size rather than widening the query' do
      cookies['fa_per_page_users'] = '100000'

      get '/admin/test/embedded_list'

      expect(rendered_rows).to eq(FlexiAdmin::Config.configuration.paginate_per)
    end
  end
end
