# Users UI Test Cases

## Context
This document outlines UI-focused test cases for the User Management module (List and Detail views). These tests focus on UI capabilities and interactions, excluding complex business logic validation.

## 1. Users List Page
**URL:** `/users`

### Search & Filter
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UL-001** | **Search by Full Name**<br>Enter a known user's name (e.g., "Balická") in the "jméno, email" input and press Enter (or wait for debounce). | Only records matching the name are displayed. Total count updates. |
| **UL-002** | **Search by Email**<br>Enter a known email (e.g., "balicka@hristehrou.cz") in the search input. | Only the specific user record is displayed. |
| **UL-003** | **Search by Partial Text**<br>Enter a partial string (e.g., "effen") in the search input. | Users containing "effen" in name or email are listed (e.g., "Effenberger", "effenberger@..."). |
| **UL-004** | **Filter by Role**<br>Select a specific role (e.g., "admin") from the "Role" dropdown. | Only users with the selected role are displayed. |
| **UL-005** | **Clear Filters**<br>Apply search text and role filter, then click "Zrušit" (Cancel). | All filters are cleared, input becomes empty, role resets, and full user list is shown. |

### Sorting
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UL-006** | **Sort by Full Name**<br>Click the "Celé jméno" column header. | List reorders alphabetically by name. Clicking again toggles ascending/descending. |
| **UL-007** | **Sort by Email**<br>Click the "Email" column header. | List reorders alphabetically by email. |
| **UL-008** | **Sort by Personal Number**<br>Click the "Osobní číslo" column header. | List reorders numerically/alphanumerically by personal number. |
| **UL-009** | **Sort by Last Login**<br>Click the "Poslední přihlášení" column header. | List reorders by date/time of last login. |

### Selection & Bulk Actions
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UL-010** | **Select All Records**<br>Check the checkbox in the table header. | All visible user rows are selected (checked). |
| **UL-011** | **Select Individual Record**<br>Check the checkbox next to a specific user. | Only that specific user row is selected. |
| **UL-012** | **Multi-selection**<br>Select several random users manually. | Multiple rows remain selected simultaneously. |
| **UL-013** | **Bulk Actions Availability**<br>Select one or more users and click the "Akce" (Actions) dropdown. | Dropdown opens showing available actions (e.g., Delete, Export). |
| **UL-014** | **Bulk Actions Inactive**<br>Ensure no users are selected and check "Akce" dropdown. | Dropdown should likely be disabled or show no valid actions. |

### Pagination & Layout
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UL-015** | **Change Records Per Page**<br>Select a different number (e.g., 32) from the items per page dropdown (bottom right). | The list updates to show more items; the total number of pages decreases. |
| **UL-016** | **Next Page Navigation**<br>Click the ">" (Next) button. | View navigates to the next set of records. Page indicator updates. |
| **UL-017** | **Previous Page Navigation**<br>Go to page 2, then click "<" (Previous). | View returns to the previous set of records. |
| **UL-018** | **Specific Page Selection**<br>Click a specific page number (e.g., "3"). | View navigates directly to that page. |
| **UL-019** | **Toggle Grid View**<br>Click the Grid View icon (next to List View icon). | Layout changes from table rows to card/grid format. |
| **UL-020** | **Toggle List View**<br>Switch back to List View. | Layout returns to the table format. |

---

## 2. User Detail Page
**URL:** `/users/[id]`

### Navigation & Layout
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UD-001** | **Breadcrumb Navigation**<br>Click the "Uživatel" or parent link in the breadcrumb "Uživatel / [Name]". | Navigates back to the Users List page. |
| **UD-002** | **Back Link/Cancel**<br>If a "Back" or cancel button exists (check specific UI context), click it. | Returns to the Users List page. |

### Data Display & Interaction
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UD-003** | **View Key Information**<br>Verify all read-only fields (Created, Updated, Login stats) are visible. | Data matches the record selected from the list. |
| **UD-004** | **Edit Text Fields**<br>Modify "Jméno a příjmení", "Email", "Telefon", or "Osobní číslo". | Fields accept input. Form is in "dirty" state (if applicable). |
| **UD-005** | **Change Role**<br>Click a different option in the "Role" multi-button selector (e.g., switch 'internal' to 'admin'). | The selected option highlights; previous selection deselects. |
| **UD-006** | **Change Type**<br>Click a different option in the "Typ" multi-button selector. | The selected option highlights. |

### Actions
| ID | Test Case | Expected Result |
| :--- | :--- | :--- |
| **UD-007** | **Wait for Auto-Save / Save**<br>Make a change and observe if there is an explicit "Save" button or auto-save indicator. | Changes are persisted (verify by reloading or returning to list). *Note: Screenshot showed no obvious 'Save' button, suggesting auto-save or context-menu save.* |
| **UD-008** | **Edit Mode Toggle**<br>Click the "Pencil" icon (top right actions). | Checks if this enables specific editing capabilities or is just a visual indicator for the current form. |
| **UD-009** | **Delete User**<br>Click the "Trash" icon (top right actions). | A confirmation dialog/prompt appears before permanent deletion. |
