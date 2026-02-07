# FlexiAdmin Architecture: A Developer's Guide

You're new to this codebase. You see controllers that barely do anything, components that inherit from gem classes you can't easily see, templates that call methods that don't seem to exist, and a `context_params` object that's passed around everywhere but never explained. This document explains how all the pieces fit together.

## The Big Picture

FlexiAdmin is a custom gem that gives you a full CRUD admin interface using three Rails patterns layered together:

1. **A controller mixin** that provides all CRUD actions with smart defaults
2. **ViewComponent classes** that compose the UI in a hierarchy
3. **Slim templates** with a DSL that describes tables, forms, and actions declaratively

The app customizes each layer by overriding just the parts it needs. Most of the behavior is inherited from the gem.

## How a Request Actually Flows

Let's trace what happens when someone visits `/admin/customers` (the customer index page), step by step.

### Step 1: Routing

```ruby
# config/routes.rb
namespace 'admin', path: nil, subdomain: 'admin' do
  resources :customers, concerns: :resourceful
end
```

The `resourceful` concern adds three extra routes on top of standard REST:

```ruby
concern :resourceful do
  post :bulk_action, on: :collection   # Batch operations on selected items
  get :datalist, on: :collection       # Simple autocomplete (returns strings)
  get :autocomplete, on: :collection   # Rich autocomplete (returns records)
end
```

So every resource gets the 7 standard REST routes + 3 FlexiAdmin routes.

### Step 2: The Controller

```ruby
# app/controllers/admin/customers_controller.rb
class Admin::CustomersController < AdminController
  def index
    authorize! :read, Customer
    @customers = Customers::Services::List.run!(**attributes)
    @customers = @customers.paginate(**context_params.pagination)
    render_index(@customers)
  end
end
```

This is **all** you write for a typical index action. Three lines. Here's what you don't see:

- `AdminController` includes `FlexiAdmin::Controllers::ResourcesController`, which provides `render_index`, `context_params`, `fa_sorted?`, and all the other CRUD actions (`show`, `create`, `update`, `destroy`, `edit`, `autocomplete`, `bulk_action`)
- You **only override** the actions where you need custom behavior. If your `index` just does `Model.all.paginate(...)`, you could even skip writing it
- `context_params` is built automatically from the request's `fa_*` query parameters (more on this below)
- `render_index` does the heavy lifting of finding the right component class and rendering it

### Step 3: render_index and Component Discovery

When you call `render_index(@customers)`, the gem does this:

```ruby
# Inside FlexiAdmin::Controllers::ResourcesController
def render_index(resources)
  respond_to do |format|
    format.html do
      # Builds class name: Admin::Customer::IndexPageComponent
      component_class = namespaced_class('namespace', resource_class.name, "IndexPageComponent")
      render component_class.new(resources, context_params:, scope: 'customers')
    end
    format.turbo_stream do
      # For Turbo partial updates, renders just the resources list
      component_class = namespaced_class('namespace', resource_class.name, "ResourcesComponent")
      render turbo_stream: turbo_stream.replace(target, component_class.new(resources, ...))
    end
  end
end
```

**This is the key convention**: the gem infers component class names from the controller. `Admin::CustomersController` becomes `Admin::Customer::IndexPageComponent`. You don't configure this mapping anywhere - it's derived from the controller name.

The same pattern applies to all actions:
- `show` → `Admin::Customer::Show::PageComponent`
- `edit`/`update` → `Admin::Customer::Show::EditFormComponent`
- `create` (service) → looks for `Customers::Services::Create`, falls back to generic

### Step 4: The Component Hierarchy

Here's where it gets layered. For an index page, you have:

```
Admin::Customer::IndexPageComponent          ← your class (often empty)
  └─ renders its .html.slim template
     └─ which renders FlexiAdmin's IndexPageComponent
        └─ with a filter slot
        └─ with Admin::Customer::ResourcesComponent
           └─ which creates a Context object
           └─ renders Admin::Customer::View::ListViewComponent
              └─ which uses the list_view DSL
```

Your Ruby class is almost always empty:

```ruby
class Admin::Customer::IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
end
```

The real customization happens in the Slim template:

```slim
/ app/components/admin/customer/index_page_component.html.slim
= render FlexiAdmin::Components::Resources::IndexPageComponent.new(resources,
                                         scope: 'customers',
                                         title: 'Zákazníci',
                                         context_params:) do |c|

  - c.with_filter
    = render FlexiAdmin::Components::Resource::FilterComponent.new(
        filter_options: { owner_id: { options: User.with_customers.sorted.map { ... } } },
        params:,
        search_field: text_field_tag('q', params[:q], ...),
        field_labels: { "q" => "Hledat", "owner_id" => "Obchodní zástupce" })

  = render Admin::Customer::ResourcesComponent.new(resources, context_params:)
```

**Why the double render?** Your `IndexPageComponent` class exists so the gem can find it by convention. But your template re-renders the gem's `IndexPageComponent` with actual parameters (title, filter options, etc.). The gem provides the page structure (title bar, filter slot, content area); your template fills in the domain-specific content.

### Step 5: ResourcesComponent and Context

`ResourcesComponent` is the piece that manages the list of records. It has two class-level settings:

```ruby
class Admin::Customer::ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
  self.scope = 'customers'      # Used for routing, Turbo frame IDs, bulk actions
  self.views = %w[list grid]    # Which view modes are available
end
```

Inside, it builds a `Context` object:

```ruby
def context
  @context ||= FlexiAdmin::Models::Resources::Context.new(
    resources,        # The ActiveRecord collection
    scope,            # 'customers'
    context_params,   # Pagination, sorting, parent info
    options           # Views, parent, title, etc.
  )
end
```

This `Context` object is what gets passed down to every child component. It bundles together the data, the URL state, and the configuration into a single object that travels down the tree. You'll see `context` as a parameter in list views, grid views, action components, etc.

### Step 6: The List View DSL

The actual table definition is pure Slim DSL:

```slim
/ app/components/admin/customer/view/list_view_component.html.slim
= list_view do
  - selectable
  - column :name, label: 'Zákazník', sortable: true do |customer|
    - navigate_to customer.name, customer
  - column :identification_number, label: 'IČ', sortable: true do |customer|
    - navigate_to customer.identification_number, customer
  - column :owner, label: 'Obchodní zástupce' do |customer|
    - if customer.owner
      - navigate_to customer.owner.full_name, customer.owner
```

- `list_view` — sets up the table container and iteration over resources
- `selectable` — adds a checkbox column for bulk actions
- `column :attr, label:, sortable:` — defines a column; block receives each resource
- `navigate_to text, resource` — renders a link to the resource's show page

These methods come from `FlexiAdmin::Components::Resources::ListViewComponent` and its included helpers. They're not defined in your code — they come from the gem's base class.

## The Context Params System

This is probably the most confusing part when you first encounter it. Every admin URL can carry a set of `fa_*` query parameters:

| Query param | Internal key | Purpose |
|---|---|---|
| `fa_scope` | `scope` | Resource type identifier |
| `fa_page` | `page` | Current page number |
| `fa_per_page` | `per_page` | Items per page |
| `fa_parent` | `parent` | **Encoded GlobalID** of parent resource |
| `fa_frame` | `frame` | Target Turbo Frame for updates |
| `fa_sort` | `sort` | Column to sort by |
| `fa_order` | `order` | Sort direction (asc/desc/default) |
| `fa_form_disabled` | `form_disabled` | Whether the form is read-only |
| `fa_view` | `view` | Current view mode (list/grid) |

The `ContextParams` class translates between these two representations. In the controller you access them as:

```ruby
context_params.pagination   # => { page: 2, per_page: 16 }
context_params.parent       # => "gid://hriste/Playground/42" (encoded)
context_params[:sort]       # => "name"
```

**Why GlobalID for parents?** When you view elements nested under a playground (`/admin/playgrounds/42/elements`), the parent relationship is encoded as a GlobalID in `fa_parent`. This means any component can reconstruct the parent object without knowing the route structure. The gem uses `GlobalID::Locator.locate(gid)` to find the parent record.

## Show Pages and Forms

Detail pages follow a different pattern. The gem calls:

```ruby
# Inside ResourcesController#show
component = namespaced_class('namespace', resource_class.name, "Show", "PageComponent")
render component.new(@resource, context_params:, scope: 'customers')
```

Your `ShowPageComponent` typically defines helper methods for nested resources:

```ruby
class Admin::Customer::Show::PageComponent < Resource::ShowPageComponent
  def contacts
    paginate(resource.contacts)
  end

  def playgrounds
    paginate(resource.playgrounds.kept)
  end
end
```

And the template composes the form + nested resource lists:

```slim
= render Resource::ViewComponent.new(context) do |c|
  - c.with_form do
    = render Admin::Customer::Show::EditFormComponent.new(resource, disabled: disabled)

  .d-flex.flex-column.gap-4
    div
      h2 Hřiště
      = render Admin::Playground::ResourcesComponent.new(playgrounds, context_params:, parent: resource)
```

**Note the `parent: resource`** on nested ResourcesComponents. This encodes the parent into context_params so that "create new" actions inside the nested list know which parent to associate with.

### Forms

Forms use a similar DSL:

```slim
= form do
  = text_field :name, label: 'Název'
  = select_field :inspector_id, label: 'Kontroloval', options: Inspection.inspector_options
  = custom_field Resource::AutocompleteComponent.new(resource.playground, ...), label: 'Hřiště'
  = submit
```

These helpers (`form`, `text_field`, `select_field`, `custom_field`, `submit`) come from `FlexiAdmin::Components::Resource::FormMixin`, included in the `FormComponent` base class.

The form posts to the standard `update` action. The gem handles the response:
- **Success** → re-renders the form in disabled (read-only) mode via Turbo Stream
- **Validation errors** → re-renders the form in enabled mode with error messages

## The Alias System

In `config/initializers/flexi_admin.rb`, you'll see:

```ruby
module Resource
  AutocompleteComponent = FlexiAdmin::Components::Resource::AutocompleteComponent
  ShowPageComponent = FlexiAdmin::Components::Resource::ShowPageComponent
  ViewComponent = FlexiAdmin::Components::Resource::ViewComponent
  FormComponent = FlexiAdmin::Components::Resource::FormComponent
end
```

These aliases exist purely for ergonomics. Instead of writing `FlexiAdmin::Components::Resource::FormComponent` everywhere, you write `Resource::FormComponent`. When you see `Resource::Something` in the codebase, it's always a FlexiAdmin gem class.

Similarly:
- `Actions::SelectComponent` → `FlexiAdmin::Components::Actions::SelectComponent`
- `Toast` → `FlexiAdmin::Models::Toast`

## Turbo Integration

FlexiAdmin is built on Turbo. When a user sorts a column, switches views, or paginates:

1. The browser makes a **Turbo Stream** request (not a full page load)
2. The controller's `render_index` detects `format.turbo_stream`
3. It renders just the `ResourcesComponent` and wraps it in a `turbo_stream.replace`
4. Only the table/grid portion of the page updates

This is why `fa_frame` exists in context_params — it tells the gem which Turbo Frame to replace. The layout contains strategic `turbo_frame_tag` anchors:
- `#system` — for redirects and system messages
- `#toasts` — for flash notifications
- Each resource list gets its own frame ID based on `scope`

## Bulk Actions

Bulk actions are modals that operate on selected records. They're self-contained components:

```ruby
class Admin::Element::Action::NewElement < FlexiAdmin::Components::Resources::BulkAction::ModalComponent
  button 'Nový prvek', icon: 'plus-circle'
  title 'Nový prvek hřiště'

  class Processor
    def initialize(resources, params)
      @resources = resources
      @params = params
    end

    def perform
      # Do the work, return OpenStruct with :result, :success, :message
    end
  end
end
```

The pattern: the outer class defines the modal UI, the nested `Processor` class handles the business logic. The `perform` method returns a result object that tells the gem what to do next (show success toast, redirect, show error).

## Mental Model: What You Need to Write vs. What the Gem Gives You

**The gem provides:**
- All CRUD controller actions (show, create, update, destroy, edit)
- Component discovery by naming convention
- Pagination, sorting, view switching
- Turbo Stream responses
- Form rendering and re-rendering
- Autocomplete infrastructure
- Bulk action framework
- Breadcrumbs, layout structure

**You provide:**
- Custom `index` action (if you need filtering/custom queries)
- `resource_params` (always required — which attributes are permitted)
- Component classes (mostly empty, for the convention to work)
- Slim templates (where the actual UI decisions live)
- Service classes for create/update (optional — gem has generic fallbacks)

## Common "Where is this defined?" Answers

| You see this... | It comes from... |
|---|---|
| `context_params` | `ResourcesController` mixin, built from `fa_*` URL params |
| `render_index(resources)` | `ResourcesController` mixin |
| `fa_sorted?`, `fa_sort`, `fa_order` | `ResourcesController` mixin |
| `list_view`, `column`, `navigate_to` | `ListViewComponent` base class in the gem |
| `form`, `text_field`, `submit` | `FormMixin` module in the gem |
| `context` (in templates) | `ResourcesComponent#context` method → `Context` object |
| `resource` (in show/form templates) | `ShowPageComponent` / `FormComponent` base class attr |
| `resources` (in index templates) | `IndexPageComponent` attr, passed from controller |
| `Resource::FormComponent` | Alias defined in `config/initializers/flexi_admin.rb` |
| `parent_instance` | `ResourcesController` — locates the parent from `fa_parent` GlobalID |

## Adding a New Resource: The Checklist

1. **Route** — Add `resources :things, concerns: :resourceful` in the admin namespace
2. **Controller** — Create `Admin::ThingsController < AdminController` with at least `index` + `resource_params`
3. **Components** — Create these files (Ruby class + Slim template for each):
   - `admin/thing/index_page_component`
   - `admin/thing/resources_component`
   - `admin/thing/view/list_view_component`
   - `admin/thing/show/page_component`
   - `admin/thing/show/edit_form_component`
4. **Follow the patterns** — Copy from an existing resource (Customer is a good simple example) and adapt

The Ruby classes are mostly empty boilerplate. The real work is in the Slim templates where you define your columns, form fields, and nested resources.

---

## Code Smells, Inconsistencies, and Sharp Edges

This section documents real problems you'll encounter. Knowing these upfront saves hours of confusion.

### 1. The Double-Render Anti-Pattern (IndexPageComponent)

Every app-side `IndexPageComponent` inherits from the gem's `IndexPageComponent`, but then its Slim template **re-instantiates the gem's class** and renders it:

```ruby
# The Ruby class — inherits from gem
class Admin::Customer::IndexPageComponent < FlexiAdmin::Components::Resources::IndexPageComponent
end
```

```slim
/ The template — renders the gem class AGAIN with new()
= render FlexiAdmin::Components::Resources::IndexPageComponent.new(resources,
                                         scope: 'customers',
                                         title: 'Zákazníci',
                                         context_params:) do |c|
  ...
```

This means the app component exists **only** so `namespaced_class` can find it by convention. Its own initialization parameters (passed by the controller via `render_index`) are thrown away. The template re-creates the parent with new parameters (title, scope). The app class is a dead shell — its `resources`, `context_params`, and `scope` attributes are set by the controller but never used by its own template.

This is confusing because it looks like the class should do something. A cleaner design would either use the inherited attributes directly or not require the subclass at all.

### 2. The `update` Action Has a Likely Bug

```ruby
# resources_controller.rb:149
result = nil
if result = try(:update_service, resource: @resource, params: resource_params)
  Rails.logger.debug "ResourcesController: #{__method__} using custom controller update_service."
  result = update_service(resource: @resource, params: resource_params)  # ← called TWICE
```

The `try(:update_service, ...)` call already invokes the method and assigns the result. Then the next line calls `update_service` again. The service runs twice on every update when a controller defines `update_service`. Compare with `create`, which correctly uses `respond_to?(:create_service)` (a check, not a call):

```ruby
# resources_controller.rb:99 — create does it correctly
if respond_to?(:create_service)
  result = create_service(resource: parent_instance, params: resource_params)
```

### 3. Service Discovery Asymmetry (create vs update)

The `create` action looks for `Customers::Services::Create` (singular namespace path):
```ruby
namespaced_class('namespace', resource_class.model_name.plural.camelize, "Services", "Create")
# → Admin::Customers::Services::Create
```

The `update` action looks for a different path with a **doubled namespace**:
```ruby
namespaced_class('namespace', 'namespace', "#{resource_class.model_name.plural.camelize}", "Services", "Update")
# → Admin::Admin::Customers::Services::Update  ← this is wrong
```

The `'namespace'` string appears twice in the `update` call. This means the auto-discovery of update services via convention will always fail with `NameError` and fall back to the generic `FlexiAdmin::Services::UpdateResource`. It only works when controllers explicitly define an `update_service` method. The `create` path works correctly.

### 4. Two Different `ViewComponent` Classes With the Same Name

The gem has:
- `FlexiAdmin::Components::Resources::ViewComponent` — wraps a **list** of resources (used in `resources_component.html.slim`)
- `FlexiAdmin::Components::Resource::ViewComponent` — wraps a **single** resource detail page (used in `show/page_component.html.slim`)

Note the difference: `Resources` (plural) vs `Resource` (singular). Both are called `ViewComponent`. The app aliases the singular one as `Resource::ViewComponent`. When you see `ViewComponent` in a template, you need to check whether you're in a list context or a detail context to know which one it is.

### 5. `context_params` vs `Context` — Two Objects, Overlapping Responsibility

- `ContextParams` — a controller-level object that wraps URL query parameters (`fa_*`). Passed down through components.
- `Context` — a component-level object built by `ResourcesComponent#context` that bundles resources + scope + context_params + options.

The confusion: some components receive `context_params` directly (IndexPageComponent, ShowPageComponent). Others receive `context` which *contains* context_params. The `ListViewComponent` and `GridViewComponent` receive `context`. The `ResourcesComponent` receives `context_params` and *builds* `context`. There's no clear rule for which object you're working with at any given layer — you need to check each component's initializer.

### 6. Scope Is Defined in Three Places and Sometimes Mismatched

The `scope` string (e.g. `'customers'`) appears in:
1. `ResourcesComponent` class: `self.scope = 'customers'`
2. The `IndexPageComponent` template: `scope: 'customers'`
3. The `ResourcesComponent` template: `Actions::SelectComponent.new(scope: ...)`

For point 3, some templates use `context.scope` (the correct way — single source of truth):
```slim
= render Actions::SelectComponent.new(scope: context.scope)
```

But others hardcode the scope string, and **some use the wrong scope entirely**:
```slim
/ observation/resources_component.html.slim
= render Actions::SelectComponent.new(scope: 'inspections')  / ← should be 'observations'
```

The Observation resource has `self.scope = 'observations'` in its Ruby class, but its template passes `scope: 'inspections'` to the actions component. This means bulk actions on observations route to the inspections controller.

### 7. `with_search` vs `with_filter` — Slot Confusion

The gem's `IndexPageComponent` defines two separate slots:
```ruby
renders_one :search
renders_one :filter
```

The template renders them differently:
```slim
- if show_search
  = search        / ← controlled by show_search boolean
- if filter
  = filter        / ← always shown if provided
```

But the app uses them interchangeably. Some index pages put a FilterComponent into `c.with_search`, others use `c.with_filter`:

| Resource | Slot used | Content |
|---|---|---|
| Customer | `c.with_filter` | FilterComponent |
| Order | `c.with_filter` | FilterComponent |
| Inspection | `c.with_search` | FilterComponent |
| Observation | `c.with_search` | FilterComponent (different fields) |
| Playground | `c.with_search` | AutocompleteComponent |
| Element | `c.with_search` | AutocompleteComponent |

There's no enforced semantic difference. It happens to work because both slots render in the same place, but the `show_search` boolean controls only the `search` slot. If someone sets `show_search: false`, the filter-in-search-slot pages would break.

### 8. Hardcoded Czech Mixed With English

The gem hardcodes Czech strings in some places and English in others, with no consistent i18n:

**Czech (hardcoded in gem):**
- `submit` button default label: `'Uložit'` (form_mixin.rb:148)
- Cancel button: `'Zrušit'` (form_mixin.rb:162)
- Record count: `'záznamů'` (view_component.html.slim:12)
- Selection text: `'vybráno'`, `'zrušit výběr'` (view_component.html.slim)

**English (hardcoded in gem):**
- Delete confirmation: `"Are you sure you want to delete this #{resource.class.model_name.human.downcase}?"` (resource/view_component.html.slim:24)
- `title` fallback: `"#{resource.class.name}: title method not implemented"` (resource/view_component.rb:28)

**Using I18n (correctly):**
- `flexi_admin.messages.destroy.success` / `.failure`
- `flexi_admin.filters.cancel` with Czech default

The gem was clearly built for a Czech-language app first and never properly internationalized. If you ever need to add English or another language, you'll need to replace all these hardcoded strings.

### 9. `render_custom_field` Hardcodes `label_tag('autocomplete', ...)`

```ruby
def render_custom_field(view_component_instance, label, html_options, _value)
  content_tag(:div, html_options.merge(class: 'form-row')) do
    unless label == false
      concat content_tag(:div, class: 'col-12 col-md-3') {
              label_tag('autocomplete', label)   # ← hardcoded 'autocomplete' for ALL custom fields
            }
    end
```

Every custom field's `<label>` tag has `for="autocomplete"`, regardless of what the field actually is. This is wrong for accessibility (multiple labels pointing to the same non-existent ID) and was clearly written when autocomplete was the only custom field type.

### 10. Debug Artifacts Left in Gem Code

The gem contains:
- `puts "component_class: #{component_class}"` in `render_index` (resources_controller.rb:42) — prints to stdout on every index page load
- `puts "here"` in breadcrumbs_component.html.slim:9
- 12+ commented-out `binding.pry` statements across resource_helper.rb
- One **active** `binding.pry` in grid_view_component.rb:48 (in error handler) — will halt production if triggered
- `# TODO: improve this` in bulk_action (resources_controller.rb:227)
- Commented-out error rescue in base_component.rb with a `@@once` class variable hack

### 11. `paginate?` Always Returns True

```ruby
# context.rb:45
def paginate?
  options.key?(:paginate) || true
end
```

The `|| true` makes this method always return `true`. It was likely meant to be:
```ruby
options.fetch(:paginate, true)
```

### 12. The `disabled?` Method Is Confusing

The controller mixin has:
```ruby
def disabled?(form_disabled = false)
  if defined?(CanCan)
    !current_ability&.can?(:update, resource_class) || form_disabled
  else
    form_disabled
  end
end
```

And `FormComponent` has its own `disabled` method:
```ruby
def disabled
  if defined?(CanCan)
    !helpers.current_ability&.can?(:update, resource_to_check) || @disabled
  else
    @disabled
  end
end
```

Both do the same CanCan check, but at different layers (controller vs component). The controller calls `disabled?(disabled?(true))` and `disabled?(disabled?(false))` — wrapping the method in itself. This double-wrapping happens because `render_edit_resource_form(disabled: disabled?(true))` passes the result to the component, which then runs the same CanCan check again. The authorization check runs twice per render, and the nesting of `disabled?` calls is hard to follow.

### 13. `hidden__field` Typo

```ruby
# form_mixin.rb:80
hidden__field = hidden_field(attr_name, value: 0)
# ...
hidden__field + checkbox
```

The double underscore `hidden__field` is a typo (should be `hidden_field_tag` or `hidden_input`). It works because Ruby doesn't care about naming, but it signals hastily-written code and will confuse anyone reading it.

### 14. `resource__path` Method Name

```ruby
# resource_helper.rb:68
def resource__path
  namespaced_path("namespace", scope_singular)
end
```

Another double-underscore method name. This exists alongside `resource_path`, creating confusion about which to use. The double underscore appears to be a workaround to avoid name collisions rather than a deliberate convention.

### 15. Class-Level Mutable State on Components

```ruby
class Admin::Customer::ResourcesComponent < FlexiAdmin::Components::Resources::ResourcesComponent
  self.scope = 'customers'
  self.views = %w[list grid]
end
```

These are `class_attribute` accessors (via `class << self; attr_accessor`). In Ruby, `attr_accessor` on a class's eigenclass creates mutable class-level state that's shared across all instances and inherited by subclasses. If a subclass modifies `self.views`, it mutates the array in place on the parent unless explicitly overridden. This hasn't caused bugs yet because each resource component sets its own values, but it's a fragile pattern.

### 16. The `SwitchViewComponent` Is Rendered Inconsistently

Some `resources_component.html.slim` templates include the view switcher, others don't — even when `self.views = %w[list grid]` declares multiple views:

```slim
/ element — has SwitchViewComponent
= render FlexiAdmin::Components::Resources::SwitchViewComponent.new(context)

/ order — no SwitchViewComponent, but only has list view so this is fine
/ (no switch view line)
```

But the decision of whether to render the switcher is manual. The gem doesn't auto-render it when multiple views are declared. You have to remember to add the line. If you declare `self.views = %w[list grid]` but forget the switcher line, the grid view exists but is unreachable.

### Summary

The gem works and powers the entire admin interface effectively. But it shows signs of organic growth: the update bug, the doubled namespace, hardcoded strings in two languages, debug `puts` in production paths, and accessibility issues. The main architectural weakness is the double-render pattern for IndexPageComponent — the indirection exists purely to satisfy a naming convention and makes the real data flow hard to trace. When working with this codebase, lean on copying existing working examples rather than trying to reason from first principles about how the gem's abstractions compose.
