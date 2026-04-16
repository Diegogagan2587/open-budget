# Open Budget Requirements

## 1. Purpose
Open Budget is a household finance application for planning, tracking, and executing money flows with enough forward visibility to reduce missed payments, overdrafts, and unnecessary mental load.

The app is focused on:
- planning future income and expenses
- tracking actual spending
- coordinating loans, debts, and repayment schedules
- keeping household shopping and inventory tied to future obligations
- separating planning from execution

## 2. Primary Users
- Household members who manage shared or personal budgets
- Users with irregular income or multiple income sources
- Users who want to plan spending before money arrives
- Users who need visibility into liabilities, repayments, and household needs

## 3. Core Concepts
- Account: the household tenancy boundary used for data isolation
- Budget Period: a time window for planning income and expenses
- Income Event: an expected or received inflow of money
- Planned Expense: a future obligation reserved against an income event
- Expense: a real transaction that happened
- Financial Account: a real cash-holding account such as checking or savings
- Liability: a debt or credit structure such as a credit card or personal loan
- Financial Entry: a ledger record that connects money movement to accounts, liabilities, income events, and expenses
- Shopping Item: a future purchase that can become a planned or actual expense
- Inventory Item: a household item that can trigger a shopping obligation when stock is low

## 4. Functional Requirements

### 4.1 Household and Tenant Management
- The system must isolate all data by household account.
- Users must only see records that belong to their current account.
- Users must be able to switch between allowed household accounts.

### 4.2 Budget Planning
- Users must be able to create and manage budget periods.
- Users must be able to define categories for spending.
- Users must be able to add planned line items to a budget period.
- The system must calculate budget pace and remaining amount over time.

### 4.3 Income Flow
- Users must be able to create income events with expected and received dates.
- Users must be able to mark an income event as received.
- The system must track balance carryover between income events.
- The system must support loan-type income events.
- Loan income events must generate repayment schedules.
- Loan repayment schedules must preserve paid installments when a loan is edited.
- The system must support multiple repayment frequencies, including monthly, weekly, biweekly, quincenal, and catorcenal/biweekly variants.
- The system must estimate interest dynamically while a loan is being created or edited.

### 4.4 Planned Expenses and Actual Expenses
- Users must be able to create planned expenses against an income event.
- Planned expenses must support statuses that represent future, saved, paid, spent, or transferred states.
- The system must create an actual expense when a planned expense is executed.
- Users must be able to manually apply a planned expense when needed.
- Users must be able to view planned expenses and loan payments in checklist-style views.
- The system must keep planned obligations visible even after they are executed.

### 4.5 Financial Accounts and Ledger
- Users must be able to create financial accounts such as cash, checking, and savings accounts.
- Users must be able to create liabilities such as credit cards and personal credits.
- Users must be able to record financial entries that represent money movement.
- Financial entries must link to source and destination accounts when relevant.
- Financial entries must link to liabilities when a debt is involved.
- Financial entries must link to income events or expenses when those records are the origin or destination of the movement.
- The system must keep a clear separation between planning records and ledger records.

### 4.6 Loans and Repayments
- Users must be able to create loan income events.
- The system must generate a repayment schedule automatically from the loan terms.
- Users must be able to view a loan summary page.
- The system must show total repayable amount, total interest, and installment details.
- The system must preserve completed payment history when the schedule is regenerated.
- The system must allow repayment execution to be tied to a real financial entry.

### 4.7 Shopping List and Inventory
- Users must be able to add shopping items with optional estimated amounts.
- Users must be able to mark shopping items as purchased.
- Users must be able to convert shopping items into planned expenses or actual expenses.
- Users must be able to link shopping items to existing planned expenses.
- Users must be able to maintain household inventory items.
- Low or empty inventory items should be easy to move into the shopping flow.

### 4.8 Navigation and Guidance
- Finance must have its own area in the application, separate from settings.
- Settings must remain focused on configuration and preferences.
- The app must provide a hub page that explains how the finance flow works.
- The dashboard and main navigation must expose finance entry points.

## 5. Data Requirements
- Every tenant-scoped record must include account ownership.
- Planned expenses must optionally map to actual expenses.
- Loan payment schedules must store installment state and due dates.
- Financial entries must record entry type, date, amount, and descriptions.
- Financial accounts and liabilities must maintain current balance information.
- Historical repayment and paid installment data must remain auditable.

## 6. Non-Functional Requirements
- The app must use Rails conventions and keep controller/model responsibilities separated.
- The UI must remain responsive and usable on desktop and mobile.
- The app must use Tailwind CSS for styling.
- The app must maintain strong account isolation for safety.
- The app must remain maintainable through focused, testable domain models.
- Finance behavior must be understandable without requiring a separate external system.

## 7. Out of Scope
- Complex investment portfolio management
- Tax preparation
- Bank synchronization
- Accounting-grade general ledger replacement
- Public multi-tenant collaboration between unrelated households
- Chart-heavy dashboards as the main product focus

## 8. Success Criteria
- Users can plan future money before it arrives.
- Users can see what will be spent and what has already been spent.
- Users can manage loans, repayments, accounts, and liabilities in one coherent flow.
- Users can understand the finance workflow without searching through settings.
- The system reduces missed obligations and financial guesswork.
