# frozen_string_literal: true

# Bootstrap tabs for splitting a long page (typically a show page) into sections.
#
#   = render FlexiAdmin::Components::Shared::TabsComponent.new(id: 'order') do |tabs|
#     - tabs.with_tab(key: 'prehled', label: 'Přehled')
#       = render EditFormComponent.new(resource)
#     - tabs.with_tab(key: 'kalkulace', label: 'Kalkulace', count: calculations.size)
#       = render CalculationsComponent.new(calculations)
#
# Every pane is rendered up front (plain Bootstrap panes, no lazy loading), so content keeps
# behaving exactly as it did on a single page. The open tab is kept in the URL hash
# (`#kalkulace`) by the `tabs` Stimulus controller, so a reload or a shared link reopens it;
# pass `remember: false` to opt out.
module FlexiAdmin::Components::Shared
  class TabsComponent < FlexiAdmin::Components::BaseComponent
    # One tab and its pane. The slot's block is the pane content.
    class Tab < FlexiAdmin::Components::BaseComponent
      attr_reader :key, :label, :count

      def initialize(key:, label:, count: nil, active: false)
        @key = key.to_s
        @label = label
        @count = count
        @active = active
      end

      def active?
        @active
      end

      def call
        content
      end
    end

    renders_many :tabs, Tab

    attr_reader :id, :nav_class

    def initialize(id:, remember: true, nav_class: "mb-4")
      @id = id
      @remember = remember
      @nav_class = nav_class
    end

    def remember?
      @remember
    end

    # The tab marked active:, or the first one — so the page always opens on a visible pane.
    def active_key
      @active_key ||= (tabs.find(&:active?) || tabs.first)&.key
    end

    def tab_dom_id(tab)
      "#{id}-tab-#{tab.key}"
    end

    def pane_dom_id(tab)
      "#{id}-pane-#{tab.key}"
    end

    def render?
      tabs?
    end
  end
end
