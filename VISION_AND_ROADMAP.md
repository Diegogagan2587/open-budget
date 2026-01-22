# House Brain - Vision and Roadmap

## Introduction

This document captures the philosophical vision, intentions, and future roadmap for this application. It complements the technical README.md by focusing on the "why" and "where" rather than the "how."

The vision is called **"House Brain"**—an external brain for the household that remembers obligations, anticipates needs, and reduces cognitive load. The current implementation is named **"Open Budget"** and represents the first stage of this vision, focusing on event-oriented financial planning.

This document describes where we are today, where we're going, and the principles that guide our decisions along the way.

---

## What This Application Is Today

House Brain (currently implemented as Open Budget) is an **event-oriented financial planning system**, designed to provide future visibility, prevent negative liquidity, and reduce cognitive load.

It is not a generic expense tracking app. It is a tool for **simulation, execution, and learning** based on how money actually enters and exits your life.

### Current Functionality (Real State)

#### Core

* **Income Events**

  * States: `pending` / `received`
  * Represent real moments of money inflow (paychecks, extraordinary income, loans, etc.)

* **Planned Expenses**

  * Associated with an income event
  * Represent known future obligations (payments, services, debts, necessary purchases)

* **Apply Expense / Apply Income**

  * A planned expense can be applied and converted into a **real expense**
  * A planned income can be marked as **received income**

* **Recording unplanned real expenses**

  * Allows recording unexpected expenses (Coca-Cola, food, small purchases)
  * Assigned to an income event to maintain flow coherence

* **Projected Balance**

  * The system carries forward positive or negative balances between income events
  * Balance is the main KPI

#### Visibility and Control

* Segmented view by months
* Filters by specific month
* Early detection of months with risk of negative liquidity

### Problem It Solves TODAY

* Reduces anxiety by providing future visibility
* Allows deciding before spending
* Prevents forgetting payments
* Functions as a **financial to-do list**
* Externalizes basic monetary decisions

---

## What It Is NOT

This application has clear boundaries about what it doesn't try to be:

* It is not an app with pretty charts
* It is not an educational finance app
* It is not a general productivity system
* It does not seek mass adoption

---

## Long-term Vision

House Brain will evolve into an **external brain for the household**, responsible for:

* Remembering obligations
* Anticipating needs
* Converting household chaos into executable tasks
* Reducing individual and shared mental load

The goal is not to think more, but to **think less without failing**.

---

## Guiding Principle

This is the non-negotiable rule about future obligations:

> Everything that enters the system must generate a **future obligation** (of money, time, or resources).

If something does not generate a future obligation, it does not belong in House Brain.

---

## Roadmap by Stages

The evolution of House Brain is planned across five stages:

### Stage 1: Financial Core (Current - Year 1)

**Objective:** Stability, confidence, and daily use without friction.

* Consolidate income events and planned expenses model
* Improve visibility of future balance
* Refine application flow (planned → real)
* Reduce clicks and unnecessary decisions

**Expected Result:**

> The system prevents financial errors and eliminates anxiety.

---

### Stage 2: Household Inventory (Year 1-2)

**Objective:** Anticipate purchases and avoid shortages.

* Simple inventory registration
* States: available / low / out of stock
* Relationship inventory → future expense
* Inventory generates obligations (buy, restock)

**Expected Result:**

> Less improvisation, fewer forgotten items, fewer urgent purchases.

---

### Stage 3: Food & Recipes (Year 2)

**Objective:** Plan meals without mental load.

* Recipes as entities
* Recipes contain ingredients
* Ingredients connected to inventory
* Recipe → inventory consumption → future expense

**Expected Result:**

> Eat better, spend less, decide less.

---

### Stage 4: Home Maintenance (Year 2-3)

**Objective:** Prevent deterioration from forgetfulness.

* Recurring maintenance tasks
* Date + estimated cost
* Generate future obligations

**Expected Result:**

> The home maintains itself without someone having to remember.

---

### Stage 5: Silent UX (Year 3)

**Objective:** Make the system disappear.

* Intelligent defaults
* Less manual interaction
* Obvious flows

**Expected Result:**

> The system works without asking for attention.

---

## Future Audience

House Brain is not for everyone. This is intentional:

Potentially useful for:

* People with high cognitive load (developers, freelancers, founders)
* Variable income
* People who hate improvising
* Households where mental load is unbalanced

---

## Real Success Metric

What actually matters is not what you might expect:

It is not number of users.

It is:

> How many bad decisions does the system prevent each month?

If it prevents decisions, it has value.

---

## Current State Summary

Where we are right now:

* Personal use
* Iteration based on real pain
* No immediate commercial focus
* Slow and deliberate construction

---

## Personal Problem It Solves

The original motivation and pain points that led to creating House Brain:

House Brain was born to solve concrete personal problems, not theoretical ones:

* Forgetting household and financial obligations
* Increased cognitive load from repetitive household tasks
* Lack of visibility for maintenance (e.g., air conditioning)
* Difficulty planning kitchen and pantry purchases
* Lack of structure for learning to cook without improvisation
* Mixing household decisions with mental energy destined for technical work

The goal is not to "optimize life," but to **reduce the mental effort necessary to execute it**.

House Brain acts as a system that:

* Remembers for the user
* Plans ahead
* Converts diffuse needs into clear actions
* Allows learning (e.g., cooking) without increasing cognitive load

The application is designed so the user:

* Thinks less about household logistics
* Executes more with confidence
* Reserves mental energy for creative and technical work

---

## Desired State in 5 Years

Long-term goals for House Brain:

* Reliable system
* Daily use
* Minimal UX
* Generates secondary income (~$200,000 MXN)

---

**House Brain does not promise order.**
It promises **not to fail from forgetfulness, anxiety, or improvisation**.
