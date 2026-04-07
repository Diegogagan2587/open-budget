# Open Budget - Copilot Instructions

See [README.md](../../README.md) for feature overview and [VISION_AND_ROADMAP.md](../../VISION_AND_ROADMAP.md) for philosophy and direction.

## Development Workflow

### Quick Start
- **Development server**: `bin/dev` (starts web, jobs, Tailwind CSS watcher)
- **Run tests**: `rails test`
- **Code linting**: `bin/rubocop` / Security: `bin/brakeman`

### Essential Commands
- **Rails console**: `rails console`
- **Database**: `rails db:migrate`, `rails db:reset`
- **Specific test file**: `rails test test/models/income_event_test.rb`

## Architecture

### Multi-tenant Design
- **Container**: Each `Account` represents a household
- **Scoping**: All entities scoped to `CurrentAttribute.account` or `for_account` scope
- **Security**: `AccountScoping` concern enforces account isolation in controllers
- **Auth**: Session-based with `require_authentication` before_action

### Core Domain
**Financial Core** (`IncomeEvent`, `PlannedExpense`, `Expense`, `BudgetPeriod`, `Category`):
- **Event-oriented model**: IncomeEvent → PlannedExpense → Expense (auto-created on status change)
- **Previous balance tracking**: Each IncomeEvent calculates balance from prior event
- **Pace calculations**: Tracks should-have-spent vs actual vs remaining

**Extended Domains**: Shopping (`ShoppingItem`, `InventoryItem`), Projects/Tasks, Household docs

### Controller Patterns
- Core finance controllers: accounts, budget_periods, categories, expenses, income_events, planned_expenses
- Nested resources follow REST with custom actions (e.g., `planned_expenses#apply`, `planned_expenses#move`)
- Namespaced routes: `/task/areas`, `/projects`

### View Components
- Use ViewComponent 4.1 (`app/components/`) for reusable UI
- All components styled with **Tailwind CSS**

## Code Style
- Use Tailwind CSS for all styling (no inline CSS)
- Rails 8.0.2 conventions
- Component-based views with ViewComponent

## Rails Conventions

### Model Practices
- Use scopes for queries: `IncomeEvent.pending`, `.received`, `.by_date`
- Use associations with `dependent: :destroy` or `:nullify`
- Set `account_id` via `before_validation` hook
- Use `Current.user` and `Current.account` for context

### Session & Authentication
- Session-based (not token-based)
- Signed cookies with database session store
- Pattern: Check `test/test_helper.rb` for `sign_in_as(user, account)` helper

## Testing
- **Framework**: Minitest (built-in Rails default)
- **Fixtures**: Include fixtures in all tests (auto-loaded from `test/fixtures/`)
- **Pattern**: `rails test` runs all tests in parallel
- **Integration tests**: Use `sign_in_as(user, account)` to set `Current` context
- **Best practice**: Test edge cases thoroughly (especially IncomeEvent balance calculations)

## Naming Conventions
- Class definitions use compact namespace syntax: `MyModule::OtherModule::HelloService`
- Every class must end with a Rails-appropriate suffix:
  - Service classes: `*Service`
  - Query objects: `*Query`
  - Controllers: `*Controller`
  - Components: `*Component`
  - Mailers: `*Mailer`
- Examples: `Financial::BalanceCalculator::SumService`, `Reports::ExpenseQuery`

## Common Patterns to Follow

### Adding a Feature
1. Create migration with `account_id` foreign key
2. Define model with validations and scopes
3. Add controller with `AccountScoping` concern
4. Create fixtures in `test/fixtures/`
5. Write Minitest tests covering edge cases
6. Build views using ViewComponent and Tailwind CSS
7. Add routes following REST conventions

### Querying Data
- Always use `Current.account` or `.for_account(account)` scope
- Leverage model scopes (never do raw SQL for common queries)
- Example: `IncomeEvent.for_account(Current.account).pending.by_date`

### Account Isolation
- Every query context must include account filtering
- Controllers: Use `AccountScoping` concern
- Jobs/background tasks: Pass account explicitly
- Tests: Set `Current.account` via test setup
