# Open Budget - Personal Budget Management App

A comprehensive Ruby on Rails application to manage budgets, income events, and expenses with PostgreSQL as the database. It allows you to create budget periods (monthly, quarterly, custom), plan expenses for each income payment, track expenses by category, and view dynamic pace calculations to monitor spending.

## Features

### Budget Management
- **Budget Periods**: Create and manage budget periods with start/end dates and total planned amount.
- **Budget Line Items**: Break down a budget period into categories with planned amounts.
- **Categories**: Define categories like Food, Transport, Utilities, etc.
- **Expenses**: Log expenses with date, amount, description, and category. Link expenses to budget periods.
- **Dynamic Pace**: On each budget period's page, view:
  - Amount you should have spent to date (pro rata).
  - Actual amount spent.
  - Remaining budget.

### Income & Expense Planning
- **Income Events**: Track expected and received income payments with dates and amounts.
- **Planned Expenses**: Plan how to allocate each income payment across different expense categories before the money arrives.
- **Expense Templates**: Create recurring expense templates for long-term savings goals (e.g., vacation fund, emergency fund).
- **Previous Balance Tracking**: Automatically track how negative balances from previous income events impact the current event's available budget, providing better visibility into financial flow.

#### Previous Balance Feature

The Previous Balance feature provides visibility into how financial deficits carry forward between income events:

- **Automatic Calculation**: Each income event automatically calculates the previous balance from the immediately preceding income event in the same budget period.
- **Effective Date Ordering**: Events are ordered by `received_date` (if received) or `expected_date` (if pending), ensuring chronological accuracy.
- **Cumulative Carryover**: Negative balances from previous events reduce the effective available budget for the current event, creating a cumulative chain of financial impact.
- **Visual Indicators**: 
  - Red borders and warning icons highlight income events with negative previous balances
  - Clear breakdown shows: `Income Amount - Previous Balance - Planned = Effective Remaining`
  - Color-coded displays (red for negative, green for positive)

**Example**: If your January 15th income had a -$500 deficit and your February 1st income is $2000, the effective remaining budget after planning expenses will be reduced by $500, giving you a true picture of available funds.

### User Interface
- **Responsive UI**: Browse expenses in table or card grid layouts with Tailwind CSS.
- **Visual Indicators**: Color-coded displays for negative balances, warnings, and status indicators.
- **Filtering & Searching**: Filter expenses by date range, category, and description text.

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

* **Dashboard**: Homepage shows quick links to manage budgets, income events, expenses, and categories.
* **Budget Periods**: Create a new budget period, add line items, and view pace checks.
* **Income Events**: 
  - Create income events for expected payments (salary, freelance, etc.)
  - Mark income as received when payment arrives
  - Plan expenses for each income event before receiving the money
  - View previous balance carryover from earlier income events
  - See effective remaining budget that accounts for previous deficits
* **Planned Expenses**: Allocate specific amounts from each income event to different categories and expense templates.
* **Expense Templates**: Create templates for recurring savings goals with progress tracking.
* **Expenses**: Add, edit, and delete expenses. Link expenses to budget periods automatically when using the nested form.
* **Categories**: Define or edit expense categories.

## Code Structure

* **Models**:

  * `BudgetPeriod`: has many `BudgetLineItem`, `Expense`, and `IncomeEvent`
  * `IncomeEvent`: belongs to `BudgetPeriod`, has many `PlannedExpense`
    - Tracks expected/received dates and amounts
    - Calculates previous balance from previous income events in the same budget period
    - Provides `effective_remaining_budget` that accounts for previous balance carryover
  * `PlannedExpense`: belongs to `IncomeEvent`, `Category`, and optionally `ExpenseTemplate`
    - Links planned expenses to income events
    - Can be applied to create actual expenses
  * `ExpenseTemplate`: has many `PlannedExpense`
    - Tracks progress toward savings goals
    - Supports different frequencies (one-time, monthly, etc.)
  * `BudgetLineItem`: belongs to `BudgetPeriod` and `Category`
  * `Category`: has many `Expense`, `BudgetLineItem`, and `PlannedExpense`
  * `Expense`: belongs to `Category` and optionally to `BudgetPeriod`

* **Controllers**:

  * `DashboardController#index` — main landing page.
  * `BudgetPeriodsController` — CRUD for budgets.
  * `IncomeEventsController` — CRUD for income events with receive/apply actions.
  * `PlannedExpensesController` — manage planned expenses within income events.
  * `ExpenseTemplatesController` — CRUD for expense templates.
  * `BudgetLineItemsController` — manage line items inside a budget.
  * `ExpensesController` — CRUD for expenses (nested under budgets for new/create).
  * `CategoriesController` — CRUD for categories.

* **Views**: Implemented with Tailwind CSS in ERB templates. Key pages:

  * Dashboard (`app/views/dashboard/index.html.erb`)
  * Income events index with previous balance indicators (`app/views/income_events/index.html.erb`)
  * Income event detail with effective remaining budget (`app/views/income_events/show.html.erb`)
  * Budget period overview with pace check (`app/views/budget_periods/show.html.erb`)
  * Expenses index as table or card grid (`app/views/expenses/index.html.erb`)

* **Helpers**:

  * `BudgetPeriodsHelper` for pace calculations (`should_have_spent`, `remaining_budget`).

## Testing

The application uses Minitest for testing. Comprehensive regression tests ensure the previous balance calculation works correctly across various edge cases.

Run all tests:
```bash
rails test
```

Run specific test files:
```bash
rails test test/models/income_event_test.rb
```

### Test Coverage

The `IncomeEvent` model includes comprehensive tests for:
- Previous balance calculation with events on the same date
- Handling of received vs expected dates for ordering
- Budget period isolation
- Cumulative balance carryover chains
- Year boundary handling
- Negative balance impact calculations

See `test/models/income_event_test.rb` for full test coverage.

## Future Improvements

### Planned Features

* **Shopping List**: Create and manage shopping lists linked to planned expenses and categories. Track items needed, quantities, and estimated costs before shopping trips.
* **Home Inventory Management**: Track inventory of household items (food, toilet paper, cleaning supplies, etc.) with:
  - Stock levels and low-stock alerts
  - Expiration date tracking for perishables
  - Automatic shopping list generation when items run low
  - Integration with planned expenses to budget for restocking

### Additional Enhancements

* Recurring budgets (auto-generate new periods).
* CSV import/export of expenses and budgets.
* Email or in-app notifications on over/under-spend.
* Charts and dashboards using Chartkick or Recharts.
* Pagination with Kaminari or Pagy.
* User authentication/authorization with Rails Authentication and Pundit.
* Mobile app support (React Native or PWA).
* Multi-currency support.
* Budget templates for common scenarios (student, family, freelancer).

## Contributing

1. Fork the repo.
2. Create a feature branch `git checkout -b feature/my-feature`.
3. Commit your changes `git commit -m "Add my feature"`.
4. Push to the branch `git push origin feature/my-feature`.
5. Open a pull request.

## License

MIT © Diego Vidal Lopez

