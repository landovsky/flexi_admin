// Import and register all your controllers

import { application } from "./application"

// Import dummy app controllers
import EditController from "./edit_controller"

// Register dummy app controllers
application.register("edit", EditController)
