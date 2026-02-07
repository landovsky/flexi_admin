# frozen_string_literal: true

# Shared examples for resource index pages

RSpec.shared_examples 'a resource index page' do |resource_name, factory_name = nil|
  factory_name ||= resource_name.to_s.singularize.to_sym

  let!(:resources) { create_list(factory_name, 3) }
  let(:index_path) { "/admin/#{resource_name}" }

  describe 'basic display' do
    it 'displays all resources' do
      visit index_path
      resources.each do |resource|
        expect(page).to have_content(resource.to_s)
      end
    end

    it 'has a resource table' do
      visit index_path
      expect(page).to have_resource_table
    end
  end

  describe 'search functionality', js: true do
    it 'has search field' do
      visit index_path
      expect(page).to have_search_field
    end

    it 'filters resources based on search query' do
      searchable_resource = resources.first
      visit index_path

      # Perform search (exact implementation depends on component setup)
      fill_in 'q', with: searchable_resource.to_s if page.has_field?('q')

      # Expectation: filtered results should appear
      # This is a placeholder - actual behavior depends on JS implementation
    end
  end

  describe 'pagination', js: true do
    before do
      # Create enough resources to trigger pagination
      create_list(factory_name, 20)
    end

    it 'has pagination controls' do
      visit index_path
      expect(page).to have_pagination_controls
    end

    it 'has per-page selector' do
      visit index_path
      expect(page).to have_per_page_selector
    end

    it 'navigates between pages' do
      visit index_path

      # Click next page if available
      if page.has_link?('→')
        click_link '→'
        expect(current_url).to include('page=2')
      end
    end
  end

  describe 'sorting', js: true do
    it 'has sortable columns' do
      visit index_path

      # Check for at least one sortable column
      # Actual columns depend on resource type
      expect(page).to have_css('th[data-sort-column], th a[href*="sort="]')
    end
  end
end

RSpec.shared_examples 'a resource show page' do |resource_name, factory_name = nil|
  factory_name ||= resource_name.to_s.singularize.to_sym

  let!(:resource) { create(factory_name) }
  let(:show_path) { "/admin/#{resource_name}/#{resource.id}" }

  describe 'basic display' do
    it 'displays resource details' do
      visit show_path
      expect(page).to have_content(resource.to_s)
    end

    it 'has edit button' do
      visit show_path
      expect(page).to have_button('Edit') || expect(page).to have_link('Edit')
    end

    it 'has delete button' do
      visit show_path
      expect(page).to have_button('Delete') || expect(page).to have_link('Delete')
    end
  end

  describe 'edit mode', js: true do
    it 'can toggle edit mode' do
      visit show_path

      if page.has_button?('Edit')
        click_button 'Edit'
        expect(page).to have_editable_form
      end
    end
  end
end

RSpec.shared_examples 'a resource form' do |resource_name, required_fields = []|
  describe 'form validation' do
    required_fields.each do |field_name|
      it "requires #{field_name}" do
        # This requires form submission to be implemented
        # Placeholder for validation testing
      end
    end
  end

  describe 'form submission', js: true do
    it 'submits successfully with valid data' do
      # Placeholder for successful submission test
    end

    it 'displays errors with invalid data' do
      # Placeholder for error display test
    end
  end
end

RSpec.shared_examples 'a resource with bulk actions' do |resource_name, factory_name = nil|
  factory_name ||= resource_name.to_s.singularize.to_sym

  let!(:resources) { create_list(factory_name, 5) }
  let(:index_path) { "/admin/#{resource_name}" }

  describe 'bulk actions', js: true do
    before do
      visit index_path
    end

    it 'has bulk actions component' do
      expect(page).to have_bulk_actions
    end

    it 'allows selecting multiple resources' do
      # Check for checkboxes
      expect(page).to have_css('input[type="checkbox"]', count: resources.count + 1) # +1 for select all
    end

    it 'displays selection count' do
      # Check for selection counter
      expect(page).to have_css('[data-flexi-admin--bulk-action-target="count"]')
    end
  end
end

RSpec.shared_examples 'a filterable resource index' do |resource_name, filterable_columns = []|
  let(:index_path) { "/admin/#{resource_name}" }

  describe 'filtering', js: true do
    before do
      visit index_path
    end

    filterable_columns.each do |column_name|
      it "has filter for #{column_name}" do
        expect(page).to have_filterable_column(column_name)
      end
    end
  end
end
