// FlexiAdmin Dummy App JavaScript Entry Point
import "@hotwired/turbo-rails"
import "./controllers"

// Import FlexiAdmin gem's JavaScript
// This resolves via esbuild alias to: ../../lib/flexi_admin/javascript/flexi_admin.js
import "flexi_admin"

console.log("FlexiAdmin dummy app loaded")
