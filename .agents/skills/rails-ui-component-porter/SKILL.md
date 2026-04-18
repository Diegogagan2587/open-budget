---
name: rails-ui-component-porter
description: Use this skill when asked to build, redesign, or improve Rails views, pages, dashboards, forms, tables, dialogs, navigation, or reusable UI components. Prioritize existing ViewComponents first. If missing, recreate matching shadcn/ui components using Rails ViewComponent, Tailwind, Hotwire, Turbo, and Stimulus only when needed.
license: MIT
---

# Rails UI Component Porter Skill

When working on UI tasks in this repository, follow this workflow strictly.

## Primary Goal

Build interfaces fast by reusing existing components first.  
If missing, port high-quality components into reusable Rails ViewComponents.

---

## Step 1: Inspect Existing Components First

Before generating new markup:

1. Search:

- `app/components`
- `app/views/shared`
- `app/views/components`
- existing partials
- existing helpers

2. If a matching component exists:

- reuse it
- extend it only if necessary
- do not duplicate markup

3. Prefer composition over creating new one-off components.

---

## Step 2: If Component Does Not Exist

Review shadcn/ui documentation:

https://ui.shadcn.com/docs/components

Find the closest component(s) needed for the request.

Examples:

- button
- card
- dialog
- dropdown-menu
- table
- tabs
- input
- select
- sheet
- badge
- toast
- pagination

---

## Step 3: Port Component to Rails Stack

Rebuild the component using:

- Ruby on Rails ERB
- ViewComponent
- TailwindCSS
- Turbo
- Hotwire
- Stimulus only if interaction requires JavaScript

Do NOT use React.

---

## Step 4: Preserve Fidelity

Match shadcn/ui as closely as possible:

- spacing
- dimensions
- border radius
- typography
- colors
- hover states
- focus states
- transitions
- responsive behavior
- accessibility
- keyboard navigation when relevant

---

## Step 5: Create Reusable Component

Generate:

- Ruby component class
- ERB template
- configurable options / props
- sane defaults
- examples of usage

Preferred namespace:

- `Ui::ButtonComponent`
- `Ui::CardComponent`
- `Ui::DialogComponent`
- `Ui::TableComponent`

---

## Step 6: Reuse in Final Page

Pages should use components, not repeated inline HTML.

Prefer:

```erb
<%= render Ui::CardComponent.new(...) %>
````

Instead of duplicated markup blocks.

---

## Step 7: Rails Behavior Standards

Use:

* Turbo Frames for partial updates
* Turbo Streams for async UI updates
* Stimulus for dropdowns, dialogs, tabs, toggles only when necessary

Prefer Rails-first patterns over custom JavaScript.

---

## Output Expectations

When asked to build a page:

1. identify reusable existing components
2. create missing components
3. assemble page using components
4. keep code clean and maintainable

---

## Example Triggers

* Build admin dashboard
* Create customers index page
* Improve form UI
* Add modal dialog
* Build responsive navbar
* Create pricing page
* Make this page look like shadcn/ui

---

## Anti-Patterns

Do NOT:

* duplicate existing component code
* generate huge inline ERB files
* use React
* add JS when Turbo solves it
* create inconsistent styling

---

## Success Metric

Fast delivery + reusable components + consistent premium UI.
