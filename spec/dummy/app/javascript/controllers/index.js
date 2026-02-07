// Import and register all your controllers

import { application } from "./application"

// Import dummy app controllers
import EditController from "./edit_controller"
import SearchController from "./search_controller"
import PaginationController from "./pagination_controller"
import UserFormController from "./admin/user_form_controller"
import RoleSelectorController from "./role_selector_controller"

// Register dummy app controllers
application.register("edit", EditController)
application.register("search", SearchController)
application.register("pagination", PaginationController)
application.register("admin--user-form", UserFormController)
application.register("role-selector", RoleSelectorController)
