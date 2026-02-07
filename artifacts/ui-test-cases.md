# Users UI Test Cases

## Context
This document outlines UI-focused test cases for the User Management module (List and Detail views). These tests focus on UI capabilities and interactions, excluding complex business logic validation.

## 1. Users List Page
**URL:** `/users`

### Search & Filter
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UL-001** | **Search by Full Name**<br>Enter a known user's name (e.g., "Balická") in the "jméno, email" input and press Enter (or wait for debounce). | Only records matching the name are displayed. Total count updates. | ✅ | ✅ | |
| **UL-002** | **Search by Email**<br>Enter a known email (e.g., "balicka@hristehrou.cz") in the search input. | Only the specific user record is displayed. | ✅ | ✅ | 🗑️ Duplicate of UL-001 (same search feature) |
| **UL-003** | **Search by Partial Text**<br>Enter a partial string (e.g., "effen") in the search input. | Users containing "effen" in name or email are listed (e.g., "Effenberger", "effenberger@..."). | ✅ | ✅ | 🗑️ Duplicate of UL-001 (same search feature) |
| **UL-004** | **Filter by Role**<br>Select a specific role (e.g., "admin") from the "Role" dropdown. | Only users with the selected role are displayed. | ✅ | ✅ | |
| **UL-005** | **Clear Filters**<br>Apply search text and role filter, then click "Zrušit" (Cancel). | All filters are cleared, input becomes empty, role resets, and full user list is shown. | ✅ | ✅ | |

### Sorting
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UL-006** | **Sort by Full Name**<br>Click the "Celé jméno" column header. | List reorders alphabetically by name. Clicking again toggles ascending/descending. | ✅ | ✅ | |
| **UL-007** | **Sort by Email**<br>Click the "Email" column header. | List reorders alphabetically by email. | ✅ | ✅ | 🗑️ Duplicate of UL-006 (same sorting feature) |
| **UL-008** | **Sort by Personal Number**<br>Click the "Osobní číslo" column header. | List reorders numerically/alphanumerically by personal number. | ❌ | ❌ | 🗑️ Not implemented, duplicate sorting |
| **UL-009** | **Sort by Last Login**<br>Click the "Poslední přihlášení" column header. | List reorders by date/time of last login. | ❌ | ❌ | 🗑️ Not implemented, duplicate sorting |

### Selection & Bulk Actions
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UL-010** | **Select All Records**<br>Check the checkbox in the table header. | All visible user rows are selected (checked). | ✅ | ✅ | |
| **UL-011** | **Select Individual Record**<br>Check the checkbox next to a specific user. | Only that specific user row is selected. | ✅ | ✅ | 🗑️ Covered by UL-012 (multi-selection) |
| **UL-012** | **Multi-selection**<br>Select several random users manually. | Multiple rows remain selected simultaneously. | ✅ | ✅ | |
| **UL-013** | **Bulk Actions Availability**<br>Select one or more users and click the "Akce" (Actions) dropdown. | Dropdown opens showing available actions (e.g., Delete, Export). | ⚠️ | ⚠️ | |
| **UL-014** | **Bulk Actions Inactive**<br>Ensure no users are selected and check "Akce" dropdown. | Dropdown should likely be disabled or show no valid actions. | ⚠️ | ❌ | 🗑️ Edge case, not core feature |
| **UL-021** | **Bulk Action - Selected IDs to Controller**<br>Select 2-3 users, open a bulk action modal, and submit. | The controller receives the exact IDs of the selected records in the `ids` parameter (JSON array). | ⚠️ | ❌ | |
| **UL-022** | **Selection-Dependent Action Disabled**<br>Without selecting any users, attempt to click a selection-dependent action (e.g., Delete). | The action button/link has `.disabled` class and clicking it does nothing. Modal does not open. | ⚠️ | ❌ | |
| **UL-023** | **Selection-Independent Action Always Available**<br>Without selecting any users, click a selection-independent action (e.g., Export All). | The action is clickable and opens modal/executes regardless of selection state. | ⚠️ | ❌ | |
| **UL-024** | **Selection-Dependent Action Enabled After Selection**<br>Select at least one user, verify selection-dependent action becomes enabled. | The `.disabled` class is removed from selection-dependent action buttons. Clicking opens the modal. | ⚠️ | ❌ | |

### Pagination & Layout
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UL-015** | **Change Records Per Page**<br>Select a different number (e.g., 32) from the items per page dropdown (bottom right). | The list updates to show more items; the total number of pages decreases. | ✅ | ✅ | |
| **UL-016** | **Next Page Navigation**<br>Click the ">" (Next) button. | View navigates to the next set of records. Page indicator updates. | ✅ | ✅ | |
| **UL-017** | **Previous Page Navigation**<br>Go to page 2, then click "<" (Previous). | View returns to the previous set of records. | ✅ | ✅ | 🗑️ Duplicate of UL-016 (same pagination nav) |
| **UL-018** | **Specific Page Selection**<br>Click a specific page number (e.g., "3"). | View navigates directly to that page. | ✅ | ✅ | 🗑️ Duplicate of UL-016 (same pagination nav) |
| **UL-019** | **Toggle Grid View**<br>Click the Grid View icon (next to List View icon). | Layout changes from table rows to card/grid format. | ❌ | ❌ | |
| **UL-020** | **Toggle List View**<br>Switch back to List View. | Layout returns to the table format. | ❌ | ❌ | 🗑️ Duplicate of UL-019 (same view switch feature) |

---

## 2. User Detail Page
**URL:** `/users/[id]`

### Navigation & Layout
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UD-001** | **Breadcrumb Navigation**<br>Click the "Uživatel" or parent link in the breadcrumb "Uživatel / [Name]". | Navigates back to the Users List page. | ✅ | ✅ | |
| **UD-002** | **Back Link/Cancel**<br>If a "Back" or cancel button exists (check specific UI context), click it. | Returns to the Users List page. | ✅ | ✅ | 🗑️ Duplicate of UD-001 (same navigation back) |

### Data Display & Interaction
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UD-003** | **View Key Information**<br>Verify all read-only fields (Created, Updated, Login stats) are visible. | Data matches the record selected from the list. | ✅ | ✅ | |
| **UD-004** | **Edit Text Fields**<br>Modify "Jméno a příjmení", "Email", "Telefon", or "Osobní číslo". | Fields accept input. Form is in "dirty" state (if applicable). | ✅ | ✅ | |
| **UD-005** | **Change Role**<br>Click a different option in the "Role" multi-button selector (e.g., switch 'internal' to 'admin'). | The selected option highlights; previous selection deselects. | ✅ | ✅ | |
| **UD-006** | **Change Type**<br>Click a different option in the "Typ" multi-button selector. | The selected option highlights. | ✅ | ✅ | 🗑️ Duplicate of UD-005 (same selector component) |

### Actions
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **UD-007** | **Wait for Auto-Save / Save**<br>Make a change and observe if there is an explicit "Save" button or auto-save indicator. | Changes are persisted (verify by reloading or returning to list). *Note: Screenshot showed no obvious 'Save' button, suggesting auto-save or context-menu save.* | ⚠️ | ❌ | |
| **UD-008** | **Edit Mode Toggle**<br>Click the "Pencil" icon (top right actions). | Checks if this enables specific editing capabilities or is just a visual indicator for the current form. | ✅ | ✅ | |
| **UD-009** | **Delete User**<br>Click the "Trash" icon (top right actions). | A confirmation dialog/prompt appears before permanent deletion. | ✅ | ✅ | |

---

## 3. Autocomplete Component
**Component:** `FlexiAdmin::Components::Resource::AutocompleteComponent`

The autocomplete component supports 3 action modes (`:select`, `:show`, `:input`) combined with enabled/disabled states. Each combination has distinct UI behavior.

### Action Mode: `:select` (Default)
Standard autocomplete for selecting a resource. Stores the selected resource's ID in a hidden input field.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **AC-001** | **Select Mode - Search and Select**<br>Type in the autocomplete input, wait for results, click a result. | Selected resource title appears in input. Hidden `resourceId` input contains the selected resource's ID. | ⚠️ | ❌ | |
| **AC-002** | **Select Mode - Clear Selection**<br>After selecting a resource, click the clear (X) icon. | Input clears, hidden `resourceId` input clears, clear icon hides. | ⚠️ | ❌ | |
| **AC-003** | **Select Mode - Disabled with Resource**<br>Render autocomplete with `disabled: true` and a resource pre-filled. | Shows a link to the resource (clicking navigates to resource detail). No input field visible. | ⚠️ | ❌ | |
| **AC-004** | **Select Mode - Disabled without Resource**<br>Render autocomplete with `disabled: true` and no resource. | Shows disabled empty message (default: "žádný zdroj"). No input field visible. | ⚠️ | ❌ | |

### Action Mode: `:show`
Autocomplete that displays resources for viewing/navigation. Similar to select but focused on navigation rather than form input.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **AC-005** | **Show Mode - Search and View Results**<br>Type in the autocomplete input, wait for results. | Results display without click handler (no `data-action`). Results show resource titles. | ⚠️ | ❌ | |
| **AC-006** | **Show Mode - Requires Path**<br>Render autocomplete with `action: :show` but no `path`. | Component raises error or handles missing path gracefully. | ⚠️ | ❌ | |
| **AC-007** | **Show Mode - Disabled with Resource**<br>Render autocomplete with `action: :show`, `disabled: true`, and a resource. | Shows link to resource. No input field visible. | ⚠️ | ❌ | |
| **AC-008** | **Show Mode - Disabled without Resource**<br>Render autocomplete with `action: :show`, `disabled: true`, and no resource. | Shows disabled empty message. No input field visible. | ⚠️ | ❌ | |

### Action Mode: `:input` (Datalist)
Text input with suggestions from existing values. Returns plain text values, not resources.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **AC-009** | **Input Mode - Search and Select Value**<br>Type in the autocomplete input, wait for datalist results, click a value. | Input value is set to the clicked text. No hidden ID field populated. | ⚠️ | ❌ | |
| **AC-010** | **Input Mode - Icon Differs**<br>Render autocomplete with `action: :input`. | Shows alphabet icon (`bi-alphabet`) instead of search icon (`bi-search`). | ⚠️ | ❌ | |
| **AC-011** | **Input Mode - Disabled with Value**<br>Render autocomplete with `action: :input`, `disabled: true`, and a value. | Shows the plain text value. No input field visible. No link (text only). | ⚠️ | ❌ | |
| **AC-012** | **Input Mode - Disabled without Value**<br>Render autocomplete with `action: :input`, `disabled: true`, and no value. | Shows nothing or empty state. No input field visible. | ⚠️ | ❌ | |

### Cross-Mode Behavior
| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **AC-013** | **Debounced Search**<br>Type rapidly in any enabled autocomplete. | Search request fires only after 200ms pause (debounce). Loading icon appears during fetch. | ⚠️ | ❌ | |
| **AC-014** | **Results Hide on Blur**<br>Type to show results, then click outside the autocomplete. | Results list hides after ~200ms delay (allows clicking results). | ⚠️ | ❌ | |
| **AC-015** | **Custom Scope Support**<br>Render autocomplete with a Proc scope and `target_controller`. | Autocomplete searches using the custom scope. Input name inferred from target_controller. | ⚠️ | ❌ | |
| **AC-016** | **Required Validation**<br>Render autocomplete with `required: true`, submit form without selection. | Form validation prevents submission. Invalid feedback appears. | ⚠️ | ❌ | |

---

## 4. Form Fields (FormMixin)
**Module:** `FlexiAdmin::Components::Resource::FormMixin`

The FormMixin provides a comprehensive set of form field helpers. Each field type supports common options: `label`, `value` (can be Proc), `disabled`, `required`, and various `html_options`.

### Text Field (`text_field`)
Standard single-line text input.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-001** | **Text Field - Basic Input**<br>Render a text field, type text into it. | Input accepts text, value is captured in form submission. | ⚠️ | ❌ | |
| **FF-002** | **Text Field - Disabled**<br>Render text field with `disabled: true`. | Input is grayed out and not editable. Value displays but cannot be changed. | ⚠️ | ❌ | |
| **FF-003** | **Text Field - Required**<br>Render with `required: true`, submit without value. | Label shows asterisk (*). Form validation prevents submission. Invalid feedback appears. | ⚠️ | ❌ | |
| **FF-004** | **Text Field - With Validation Error**<br>Submit form with invalid data, re-render with model errors. | Input shows `.is-invalid` class. Error message displays in `.invalid-feedback`. | ⚠️ | ❌ | |
| **FF-005** | **Text Field - Proc Value**<br>Render with `value: -> { computed_value }`. | Proc is evaluated, computed value displays in input. | ⚠️ | ❌ | |

### Number Field (`number_field`)
Numeric input with step support.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-006** | **Number Field - Basic Input**<br>Render number field, enter a number. | Input accepts numeric values. Uses default step of 0.01. | ⚠️ | ❌ | |
| **FF-007** | **Number Field - Custom Step**<br>Render with `step: 1`. | Input increments/decrements by 1. Decimal values may be rejected. | ⚠️ | ❌ | |
| **FF-008** | **Number Field - Disabled**<br>Render with `disabled: true`. | Input is not editable. Spinner controls are disabled. | ⚠️ | ❌ | |

### Checkbox Field (`checkbox_field`)
Boolean checkbox with hidden field for false value submission.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-009** | **Checkbox - Unchecked State**<br>Render unchecked checkbox, submit form. | Hidden field sends `0`. Checkbox input not sent. | ⚠️ | ❌ | |
| **FF-010** | **Checkbox - Checked State**<br>Check the checkbox, submit form. | Checkbox sends `1`, overriding hidden field's `0`. | ⚠️ | ❌ | |
| **FF-011** | **Checkbox - Toggle Interaction**<br>Click checkbox to toggle state. | Visual state changes, checked/unchecked reflects click. | ⚠️ | ❌ | |
| **FF-012** | **Checkbox - Disabled**<br>Render with `disabled: true`. | Checkbox is not clickable. Visual state is preserved but interaction blocked. | ⚠️ | ❌ | |
| **FF-013** | **Checkbox - Proc Value**<br>Render with `checked: -> { condition }`. | Proc evaluated, checkbox pre-checked based on result. | ⚠️ | ❌ | |

### Select Field (`select_field`)
Standard dropdown select.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-014** | **Select - Basic Selection**<br>Render select with options, select an option. | Selected option value is captured in form submission. | ⚠️ | ❌ | |
| **FF-015** | **Select - Pre-selected Value**<br>Render with `value: 'option2'`. | Option2 is pre-selected on render. | ⚠️ | ❌ | |
| **FF-016** | **Select - Disabled**<br>Render with `disabled: true`. | Dropdown cannot be opened. Current selection displays but cannot change. | ⚠️ | ❌ | |
| **FF-017** | **Select - Required**<br>Render with `required: true`, submit without selection. | Form validation prevents submission. Invalid feedback appears. | ⚠️ | ❌ | |
| **FF-018** | **Select - Validation Error**<br>Submit with invalid selection, re-render with model errors. | Error message displays in `.invalid-feedback`. | ⚠️ | ❌ | |

### Button Select Field (`button_select_field`)
Radio-style button group for selecting from mutually exclusive options.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-019** | **Button Select - Click to Select**<br>Click one of the option buttons. | Clicked button becomes active (visual highlight). Hidden input updates to selected value. | ⚠️ | ❌ | |
| **FF-020** | **Button Select - Single Selection**<br>Click different buttons sequentially. | Only one button remains active at a time. Previous selection deselects. | ⚠️ | ❌ | |
| **FF-021** | **Button Select - Pre-selected Value**<br>Render with `value: 'option2'`. | Option2 button is pre-highlighted on render. | ⚠️ | ❌ | |
| **FF-022** | **Button Select - Disabled**<br>Render with `disabled: true`. | Shows single disabled button with current value (or '-'). No interaction possible. | ⚠️ | ❌ | |
| **FF-023** | **Button Select - Validation Error**<br>Submit with error, re-render. | Invalid feedback displays below button group. | ⚠️ | ❌ | |

### Date Field (`date_field`)
Date picker input.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-024** | **Date Field - Date Selection**<br>Click date field, select date from picker. | Selected date appears in input (format: YYYY-MM-DD). | ⚠️ | ❌ | |
| **FF-025** | **Date Field - Manual Entry**<br>Type date directly into input. | Valid dates accepted. Input has max-width: 180px styling. | ⚠️ | ❌ | |
| **FF-026** | **Date Field - Disabled**<br>Render with `disabled: true`. | Date picker cannot be opened. Value displays but not editable. | ⚠️ | ❌ | |

### Datetime Field (`datetime_field`)
Datetime picker input.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-027** | **Datetime Field - Datetime Selection**<br>Select date and time. | Full datetime value captured (YYYY-MM-DDTHH:MM format). | ⚠️ | ❌ | |
| **FF-028** | **Datetime Field - Disabled**<br>Render with `disabled: true`. | Picker cannot be opened. Existing value displays but not editable. | ⚠️ | ❌ | |

### Text Area Field (`text_area_field`)
Multi-line text input.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-029** | **Text Area - Multi-line Input**<br>Enter multiple lines of text. | All lines captured. Textarea expands or scrolls as needed. | ⚠️ | ❌ | |
| **FF-030** | **Text Area - Disabled**<br>Render with `disabled: true`. | Text area is not editable. Content displays but cannot be modified. | ⚠️ | ❌ | |

### HTML Field (`html_field`) - Trix Editor
Rich text editor using Trix.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-031** | **HTML Field - Rich Text Formatting**<br>Use Trix toolbar to format text (bold, italic, links). | Formatted HTML is captured in hidden input. Preview shows formatted content. | ⚠️ | ❌ | |
| **FF-032** | **HTML Field - Disabled**<br>Render with `disabled: true`. | Trix editor is not editable. Content displays as HTML without editing toolbar. | ⚠️ | ❌ | |
| **FF-033** | **HTML Field - Short Text Display**<br>Render with value < 150 characters. | `short_text?` returns true (may affect styling). | ⚠️ | ❌ | |

### Custom Field (`custom_field`)
Wrapper for embedding custom ViewComponent instances in form layout.

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-034** | **Custom Field - Component Rendering**<br>Render custom_field with a ViewComponent. | Component renders inside form row layout with proper label column. | ⚠️ | ❌ | |
| **FF-035** | **Custom Field - No Label**<br>Render with `label: false`. | Component spans full width (col-md-12). No label column rendered. | ⚠️ | ❌ | |
| **FF-036** | **Custom Field - Auto Label**<br>Render without explicit label. | Label auto-generated from component class name (humanized). | ⚠️ | ❌ | |

### Form Layout & Utilities

| ID | Test Case | Expected Result | Dummy App | Test Coverage | Delete? |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **FF-037** | **Inline Fields**<br>Render multiple fields with `inline: true` inside `field` block. | Fields render side-by-side in `.inline-field-wrapper`. Single label for group. | ⚠️ | ❌ | |
| **FF-038** | **Header**<br>Render `header('Section Title', description: 'Optional description')`. | Section header with title and description displays. Full width, no input. | ⚠️ | ❌ | |
| **FF-039** | **Submit Button**<br>Render `submit('Save')`. | Primary submit button renders. Form submits on click. | ⚠️ | ❌ | |
| **FF-040** | **Submit with Cancel**<br>Render `submit` with `cancel_button: true`. | Both submit and cancel buttons render. Cancel navigates to edit path with disabled form. | ⚠️ | ❌ | |
| **FF-041** | **Submit Disabled**<br>Render submit when form is disabled. | Submit button has `disabled` attribute. Click does nothing. | ⚠️ | ❌ | |
| **FF-042** | **Add Row Button**<br>Render `add_row_button` for dynamic rows. | Button clicks trigger `add-row#add` action. New row cloned from template. | ⚠️ | ❌ | |
| **FF-043** | **Remove Row Button**<br>Render `remove_row_button` inside dynamic row. | Button clicks trigger `add-row#remove` action. Row is removed from DOM. | ⚠️ | ❌ | |
| **FF-044** | **With Resource Context**<br>Use `with_resource(other_resource)` block. | Fields inside block use the other resource for values and errors. Original resource restored after block. | ⚠️ | ❌ | |
