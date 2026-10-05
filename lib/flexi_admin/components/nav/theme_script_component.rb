# frozen_string_literal: true

# Sets <html data-bs-theme> before first paint, so dark-mode users never see a light flash.
# Render it in <head>, after the stylesheets:
#
#   = render FlexiAdmin::Components::Nav::ThemeScriptComponent.new
#
# The preference ("light" | "dark" | "auto") lives in localStorage under STORAGE_KEY and
# defaults to "auto", which follows the OS setting and reacts when it changes. Pair it with
# ThemeToggleComponent to let users switch. Pass default: "light" to ignore the OS setting
# until the user picks a theme.
module FlexiAdmin::Components::Nav
  class ThemeScriptComponent < FlexiAdmin::Components::BaseComponent
    STORAGE_KEY = "flexi-admin-theme"
    PREFERENCES = %w[auto light dark].freeze

    def initialize(default: "auto")
      @default = PREFERENCES.include?(default.to_s) ? default.to_s : "auto"
    end

    def call
      helpers.javascript_tag(script, nonce: true)
    end

    private

    def script
      <<~JS
        (function () {
          var key = #{STORAGE_KEY.to_json}, fallback = #{@default.to_json};
          var media = window.matchMedia("(prefers-color-scheme: dark)");
          function preference() {
            try { return localStorage.getItem(key) || fallback; } catch (e) { return fallback; }
          }
          function apply() {
            var pref = preference(), root = document.documentElement;
            root.setAttribute("data-bs-theme", pref === "auto" ? (media.matches ? "dark" : "light") : pref);
            root.setAttribute("data-fa-theme-preference", pref);
          }
          apply();
          media.addEventListener("change", function () { if (preference() === "auto") apply(); });
          window.FlexiAdminTheme = {
            key: key,
            preference: preference,
            set: function (pref) {
              try { localStorage.setItem(key, pref); } catch (e) {}
              apply();
            }
          };
        })();
      JS
    end
  end
end
