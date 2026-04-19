---
name: rails-ui-component-porter
description: Use this skill when asked to build Rails views, dashboards, forms, tables, dialogs, navigation, or reusable UI components. Reuse existing ViewComponents first. If missing, recreate matching shadcn/ui components using Rails ViewComponent generator, Tailwind, Hotwire, Turbo, and Stimulus only when needed.
license: MIT
allowed-tools:
  - bash
---

# Rails UI Component Porter Skill

When working on UI tasks in this repository, follow this workflow strictly.

---

## Primary Goal

Deliver premium Rails UI fast by:

1. Reusing existing components first
2. Generating missing components with ViewComponent generator
3. Porting shadcn/ui patterns into reusable Rails components
4. Building pages from components instead of duplicated markup

---

## Step 1: Inspect Existing Components First

1. Before generating anything, search:

- `app/components`
- `app/views/shared`
- `app/views/components`
- existing partials
- existing helpers

2. If a matching component exists:

- reuse it
- extend it only if necessary
- do not duplicate markup

3. Prefer composition over creating new one-off components when possible.

---

## Step 2: If Component Does Not Exist

Review shadcn/ui documentation:

https://ui.shadcn.com/docs/components

Find the closest matching component required.

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

## Step 3: Generate Using Official ViewComponent Command

Always use the Rails generator first.

Example:

```bash
bin/rails generate view_component:component Ui::Card title description etc
````

This should create files like:

* `app/components/ui/card_component.rb`
* `app/components/ui/card_component.html.erb`
* tests

Use namespaced `Ui::` components whenever appropriate.

Examples:

```bash
bin/rails generate view_component:component Ui::Button variant
bin/rails generate view_component:component Ui::Dialog title
bin/rails generate view_component:component Ui::Table rows
bin/rails generate view_component:component Ui::Badge label
```

Never manually create component files when generator is available.

---

## Step 4: Port Design to Rails Stack

After generation, implement the component using:

* ERB
* TailwindCSS
* Turbo
* Hotwire
* Stimulus only when interaction requires JavaScript

Do NOT use React.

---

## Step 5: Preserve Fidelity

Match shadcn/ui quality closely:

- spacing
- dimensions
- radius
- typography
- colors
- hover states
- focus states
- transitions
- responsive behavior
- accessibility
- keyboard support & navigation when relevant

---

## Step 6: Make Reusable

Generated components should support configurable arguments.

Example:

```ruby
Ui::ButtonComponent.new(
  label: "Save",
  variant: :primary,
  size: :md
)
```

Use sane defaults.

---

## Step 7: Reuse in Final Pages

Prefer:

```erb
<%= render Ui::CardComponent.new(title: "Revenue") do %>
  Content
<% end %>
```

Instead of repeated inline HTML.

---

## Step 8: Rails Interaction Standards

Prefer:

* Turbo Frames
* Turbo Streams
* Stimulus only when necessary

Avoid unnecessary custom JavaScript.

---

## Output Expectations

When asked to build a page:

1. Search existing components
2. Generate missing components with ViewComponent command
3. Port styles/behavior
4. Build final page using components
5. Keep code maintainable

---

## Example Triggers

* Build admin dashboard
* Create customer table
* Add modal dialog
* Build responsive navbar
* Improve settings page
* Create pricing cards
* Make this page look like shadcn/ui
* review if this page does look like shadcn/ui

---

## Anti-Patterns

Do NOT:

* duplicate components
* manually create component files if generator exists
* generate giant ERB templates
* use React
* add JS when Turbo solves it
* create inconsistent styles

---

## Success Metric

Fast delivery + reusable Rails components + premium consistent UI.
