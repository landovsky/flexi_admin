# frozen_string_literal: true

require 'rails_helper'

# Opening an autocomplete used to show nothing at all: a user facing a long list
# had to guess a search term before seeing a single option.
RSpec.describe 'Autocomplete suggestions', type: :request do
  let(:base_params) { { ac_action: 'select', ac_fields: ['full_name'] } }

  def suggestions
    Nokogiri::HTML(response.body).css('li').map { |li| li.text.strip }
  end

  context 'when the field is focused but nothing has been typed' do
    before { create_list(:user, 20) }

    it 'offers a capped list of suggestions instead of an empty dropdown' do
      get '/admin/users/autocomplete', params: base_params.merge(q: '')

      expect(response).to have_http_status(:ok)
      expect(suggestions.size).to eq(FlexiAdmin::Config.configuration.autocomplete_suggestions)
    end

    it 'caps the suggestions at whatever the host app configured' do
      allow(FlexiAdmin::Config.configuration).to receive(:autocomplete_suggestions).and_return(3)

      get '/admin/users/autocomplete', params: base_params.merge(q: '')

      expect(suggestions.size).to eq(3)
    end
  end

  context 'when the user has actually typed something' do
    before do
      create(:user, :balicka)
      create_list(:user, 20)
    end

    it 'still runs the search rather than returning the generic suggestions' do
      get '/admin/users/autocomplete', params: base_params.merge(q: 'Balick')

      expect(suggestions).to all(match(/Balick/))
    end
  end

  context 'when fewer records exist than the suggestion cap' do
    before { create_list(:user, 2) }

    it 'returns what there is without padding or erroring' do
      get '/admin/users/autocomplete', params: base_params.merge(q: '')

      expect(suggestions.size).to eq(2)
    end
  end
end
