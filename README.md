# BudgetTracker Rails App

A simple Ruby on Rails application to manage budgets and expenses with PostgreSQL as the database. It allows you to create budget periods (monthly, quarterly, custom), add line items, track expenses by category, and view dynamic pace calculations to monitor spending.

## Features

- **Budget Periods**: Create and manage budget periods with start/end dates and total planned amount.
- **Budget Line Items**: Break down a budget period into categories with planned amounts.
- **Categories**: Define categories like Food, Transport, Utilities, etc.
- **Expenses**: Log expenses with date, amount, description, and category. Link expenses to budget periods.
- **Dynamic Pace**: On each budget period’s page, view:
  - Amount you should have spent to date (pro rata).
  - Actual amount spent.
  - Remaining budget.
- **Responsive UI**: Browse expenses in table or card grid layouts with Tailwind CSS.
- **Filtering & Searching**: (Optional) Filter expenses by date range, category, and description text.

## Prerequisites

- Ruby (>= 3.0)
- Rails (>= 7.0)
- PostgreSQL

## Setup & Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/budget_tracker.git
   cd budget_tracker
   ```

2. Install gems:

   ```bash
   bundle install
   ```

3. Configure database credentials in `config/database.yml` if necessary.

4. Create and migrate the database:

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed   # loads default categories
   ```

5. Start the Rails server:

   ```bash
   rails server
   ```

6. Navigate to `http://localhost:3000` in your browser.

## Usage

* **Dashboard**: Homepage shows quick links to manage budgets, expenses, and categories.
* **Budgets**: Create a new budget period, add line items, and view pace checks.
* **Expenses**: Add, edit, and delete expenses. Link expenses to budget periods automatically when using the nested form.
* **Categories**: Define or edit expense categories.

## Code Structure

* **Models**:

  * `BudgetPeriod`: has many `BudgetLineItem` and `Expense`
  * `BudgetLineItem`: belongs to `BudgetPeriod` and `Category`
  * `Category`: has many `Expense` and `BudgetLineItem`
  * `Expense`: belongs to `Category` and optionally to `BudgetPeriod`

* **Controllers**:

  * `DashboardController#index` — main landing page.
  * `BudgetPeriodsController` — CRUD for budgets.
  * `BudgetLineItemsController` — manage line items inside a budget.
  * `ExpensesController` — CRUD for expenses (nested under budgets for new/create).
  * `CategoriesController` — CRUD for categories.

* **Views**: Implemented with Tailwind CSS in ERB templates. Key pages:

  * Dashboard (`app/views/dashboard/index.html.erb`)
  * Budget period overview with pace check (`app/views/budget_periods/show.html.erb`)
  * Expenses index as table or card grid (`app/views/expenses/index.html.erb`)

* **Helpers**:

  * `BudgetPeriodsHelper` for pace calculations (`should_have_spent`, `remaining_budget`).

## Testing

Add tests using RSpec or Minitest. Example with Minitest:

```bash
rails test
```

## Future Improvements

* Recurring budgets (auto-generate new periods).
* CSV import/export of expenses and budgets.
* Email or in-app notifications on over/under-spend.
* Charts and dashboards using Chartkick or Recharts.
* Pagination with Kaminari or Pagy.
* User authentication/authorization with Rails Authentication and Pundit.

## Contributing

1. Fork the repo.
2. Create a feature branch `git checkout -b feature/my-feature`.
3. Commit your changes `git commit -m "Add my feature"`.
4. Push to the branch `git push origin feature/my-feature`.
5. Open a pull request.

## License

MIT © Diego Vidal Lopez

