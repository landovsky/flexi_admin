# frozen_string_literal: true

require 'rails_helper'

# Exercises the gem's real show page (Resource::ViewComponent + FormMixin edit form),
# as rendered by the spec/dummy showcase app.
RSpec.describe 'User Detail Page', type: :feature, js: true do
  let(:user) { create(:user, full_name: 'Test User', email: 'test@example.com', role: 'user', user_type: 'internal') }

  def enable_editing
    find('[data-controller="form"][data-action="click->form#enable"]').click
    expect(page).to have_field('user[full_name]', disabled: false)
  end

  describe 'Navigation' do
    context 'breadcrumbs are inferred from the URL, so every detail page gets a way back for free' do
      it 'returns to the users list from the collection crumb' do
        visit "/admin/users/#{user.id}"

        within('nav.breadcrumbs') do
          expect(page).to have_css('.breadcrumb-item.active', text: 'Test User')
          click_link 'User'
        end

        expect(page).to have_css('flexi-table')
        expect(page).to have_content('Manage user accounts')
      end
    end
  end

  describe 'Read-only display' do
    context 'the edit form doubles as the detail view, rendered disabled until the user opts in' do
      it 'shows the record in disabled fields grouped by form section headers' do
        visit "/admin/users/#{user.id}"

        expect(page).to have_css('h1', text: 'Test User')
        expect(page).to have_field('user[email]', with: 'test@example.com', disabled: true)
        expect(page).to have_content('Basic Information')
        expect(page).to have_content('Role & Access')
      end
    end
  end

  describe 'Nested resources' do
    context 'a list rendered with parent: on a host app that only defines nested routes' do
      let!(:own_comment) { Comment.create!(user:, content: 'Belongs to Test User') }
      let!(:foreign_comment) { Comment.create!(user: create(:user), content: 'Belongs to someone else') }

      it "renders the parent's children via the nested route instead of crashing on a missing flat route" do
        visit "/admin/users/#{user.id}"

        expect(page).to have_css('#user-tab-comments .badge', text: '1')
        expect(page).to have_content('Belongs to Test User')
        expect(page).not_to have_content('Belongs to someone else')
        # as: :date on a timestamp column shows the date, not the full time format
        expect(page).to have_css('#user-pane-comments flexi-table', text: own_comment.created_at.to_date.iso8601)
        expect(page).to have_no_css('#user-pane-comments flexi-table', text: '+0000')
      end
    end
  end

  describe 'Tabs' do
    context 'the open tab lives in the URL hash so a reload or shared link lands on the same section' do
      it 'reopens the Activity tab after a reload' do
        visit "/admin/users/#{user.id}"
        expect(page).to have_css('#user-pane-comments.active')

        click_button 'Activity'
        expect(page).to have_css('#user-pane-activity.active', text: 'Sign-ins')
        expect(page).to have_current_path(/#activity\z/, url: true)

        page.driver.browser.navigate.refresh
        expect(page).to have_css('#user-pane-activity.active')
        expect(page).to have_no_css('#user-pane-comments.active')
      end
    end
  end

  describe 'Editing' do
    context 'edit mode is toggled server-side so the form re-renders with fresh data' do
      it 'enables fields when the pencil is clicked and disables them again on cancel' do
        visit "/admin/users/#{user.id}"
        expect(page).to have_field('user[full_name]', disabled: true)

        enable_editing
        fill_in 'user[full_name]', with: 'Updated Name'
        expect(page).to have_field('user[full_name]', with: 'Updated Name')

        find('button[data-action="click->form#disable"]').click
        expect(page).to have_field('user[full_name]', disabled: true)
      end

      it 'persists a role change made through the select field' do
        visit "/admin/users/#{user.id}"
        enable_editing

        select 'Admin', from: 'user[role]'
        click_button 'Save'

        expect(page).to have_field('user[role]', disabled: true, with: 'admin', wait: 5)
        expect(user.reload.role).to eq('admin')
      end
    end

    context 'button select stores plain values while showing human labels' do
      it 'marks the clicked option as selected and writes its value to the hidden input' do
        visit "/admin/users/#{user.id}"
        enable_editing

        within('.button-select') { click_button 'External' }

        expect(page).to have_css('.button-select .btn.selected', text: 'External')
        expect(find('input[name="user[user_type]"]', visible: false).value).to eq('external')
      end
    end
  end

  describe 'Deleting' do
    context 'deletion is irreversible, so it sits behind a confirmation dialog' do
      it 'removes the user and lands back on the index after confirming' do
        user_id = user.id
        visit "/admin/users/#{user_id}"

        accept_confirm do
          find('[data-controller="delete"]').click
        end

        expect(page).to have_css('flexi-table', wait: 10)
        expect(User.find_by(id: user_id)).to be_nil
      end
    end
  end
end
