# OrderIQ – Business Requirement Document

### Intelligent Multi-Country Sales Order Management with Automated Currency Conversion

---

## Document Purpose

This document captures the business requirements behind **OrderIQ**, a RAP (RESTful ABAP Programming Model) application built on SAP BTP ABAP Environment. It describes the business context, pain points, solution vision, scope, and detailed business stories that shaped the application — covering sales order management, master data, and multi-currency conversion end to end.

---

## 1. Business Context

NordPeak Industrial Supply GmbH is a mid-size B2B distributor of electrical and mechanical components, serving business customers across manufacturing, construction, and facilities-management sectors in multiple countries — including the US, India, Japan, China, UAE, Switzerland, and Kuwait. The company processes a steady volume of sales orders through a team of sales representatives, supported by a credit/finance team and a warehouse team responsible for stock and delivery commitments.

Because customers and products span multiple countries, each transaction happens in a **local currency** — but sales leadership manages and reports the business in a single currency, **USD**. Today, there is no reliable way to compare order value, credit exposure, or performance across regions without manual, error-prone currency conversion.

On top of this, sales orders themselves are captured with almost no built-in business logic: order numbers are assigned manually, item totals and tax are calculated by hand, delivery dates are set without checking lead times, and there is no automated check against a customer's credit limit or a product's available stock before an order is confirmed.

---

## 2. Current Pain Points

- Manual, error-prone order numbering, with occasional duplicate or conflicting IDs.
- Net amount, tax amount, and order totals calculated inconsistently, often outside the system.
- No default or validated delivery dates; commitments are made without checking lead times.
- No automatic enforcement of customer credit limits — over-limit orders are caught by finance only after the fact, sometimes after goods have shipped.
- No check that ordered quantity is actually available in stock, leading to broken delivery promises.
- Duplicate product lines within a single order, complicating fulfillment and invoicing.
- No single, trustworthy status a sales manager can look at to understand where an order stands.
- No mechanism to compare order values or customer credit exposure across different currencies.
- Exchange rates, when used at all, are looked up manually and applied inconsistently — sometimes stale, sometimes wrong.
- Customer credit limits are set in local currency, making it impossible to get a single global view of total credit exposure.
- No historical record of what exchange rate applied to a given order at the time it was placed — a compliance and audit concern.

---

## 3. Solution Vision: OrderIQ

OrderIQ is a RAP-based Sales Order Management application built to remove manual effort and manual risk from order entry, and to give the business a single, consistent, USD-based view of order value across every country it operates in.

The solution is built around three core RAP mechanisms:

- **Determinations** do the thinking the sales rep shouldn't have to — assigning order numbers, calculating net/tax/total amounts, deriving delivery dates, rolling up order and item status, and converting every local-currency amount to USD automatically, at exactly the right point in the save sequence.
- **Validations** do the protecting the business needs — blocking a save the moment an order would exceed a customer's credit limit, request more stock than is available, reference an inactive customer or product, use a currency with no valid exchange rate, or contain data that doesn't make sense (negative quantities, impossible delivery dates, duplicate items).
- **Actions** drive the order lifecycle — Release, Reject, Cancel, and Complete at the header level, and Confirm, Cancel, and Deliver at the item level — so every order moves through a clear, controlled status flow.

A customer in India orders in INR. A customer in Japan orders in JPY. A customer in the US orders in USD. Every one of those orders shows its **local currency** amount to the person who owns that relationship, and its **USD-converted** amount to the people who manage the business globally — calculated automatically, using the exchange rate that was valid on the date the order was placed.

---

## 4. Why Determinations & Validations Are Central

This application is deliberately scoped so that Determinations and Validations aren't incidental features — they *are* the product. Every "smart" behavior a stakeholder sees in a demo (auto-numbering, auto-totals, auto-status, auto-currency-conversion, auto-defaulted delivery dates) is a Determination. Every "safe" behavior (credit check, stock check, active-customer/product check, exchange-rate-availability check, data-quality checks) is a Validation. This makes the app an ideal showcase: simple enough to demo end-to-end in ten minutes, yet rich enough to exercise the full range of RAP trigger points across multiple related entities, header-level and item-level logic, and time-dependent master data.

---

## 5. Scope

**In scope:**
- Sales Order header and items (parent-child, composition relationship)
- Customer and Product master data, each linked to a country
- Country master data (11 countries seeded: AE, AL, CH, CN, DE, FR, GB, IN, JP, KW, US)
- Exchange Rate master data, time-bound (Valid From / Valid To) against USD as base currency
- Automatic conversion of item-level amounts and customer credit limits to USD
- 15+ Determinations covering numbering, pricing, currency conversion, delivery dates, and status
- 15+ Validations covering customer, credit, product, stock, currency, and data-quality checks
- Full order lifecycle actions: Release, Reject, Cancel, Complete (header) and Confirm, Cancel, Deliver (item)
- Standard RAP managed scenario with draft handling across all entities

**Out of scope:**
- Live/API-based exchange rate feeds (rates are manually maintained per validity period)
- Multi-level approval workflows
- Integration with real ERP FI-CO/MM systems
- Analytical dashboards and KPI reporting
- Full pricing/condition engine

---

## 6. Key Stakeholders

| Stakeholder | Interest |
|---|---|
| Regional Sales Representative | Fast, error-free order entry in the customer's own local currency |
| Global Sales Manager | Reliable order status and totals at a glance, consistently in USD across all countries |
| Credit Controller / Finance | Automatic credit-limit enforcement, evaluated in USD regardless of customer's local currency |
| Warehouse / Logistics Coordinator | Realistic, stock-checked delivery commitments |
| Compliance / Audit | Traceable record of which exchange rate applied to which order, at what point in time |
| IT / Solution Architect | Clean RAP reference architecture to build on |

---

## 7. Business Stories (Agile User Stories)

### Epic A — Order Numbering & Identification

**A1 — Automatic Sales Order Numbering** · *Determination*
> As a **Sales Representative**, I want the system to automatically assign a unique Sales Order number when I create a new order, so that I never have to manually track or guess order numbers.

Acceptance Criteria:
- Order ID is generated automatically on order creation.
- Order ID is read-only in the UI; manual entry is not permitted.

### Epic B — Country & Currency Setup

**B1 — Country Master Maintenance** · *Determination*
> As an **Administrator**, I want to maintain a list of countries with their associated currency, so that customers and products can be correctly linked to a currency for conversion purposes.

Acceptance Criteria:
- Country Code, Country Name, Currency Code, and Active status are maintained per country.
- Country Name is auto-derived once Country Code is entered.

**B2 — Time-Bound Exchange Rate Maintenance** · *Determination + Validation*
> As a **Finance Administrator**, I want to maintain exchange rates against USD for a specific validity period, so that historical orders always use the rate that was correct at the time they were placed.

Acceptance Criteria:
- Each Exchange Rate record has Currency, Rate Against USD, Valid From, and Valid To.
- The system prevents saving an exchange rate whose validity period overlaps with an existing active rate for the same currency.
- Rate must be a positive value; currency must exist in Country Master; Valid From must be before Valid To.

**B3 — Currency Auto-Derivation for Customers** · *Determination*
> As a **Sales Administrator**, I want a customer's currency to be automatically set based on their assigned Country, so that I don't have to manually select currency and risk a mismatch.

Acceptance Criteria:
- On customer save, Currency is auto-populated based on the customer's Country.

### Epic C — Pricing, Tax & Currency Conversion

**C1 — Automatic Item Net Amount Calculation** · *Determination*
> As a **Sales Representative**, I want each item's Net Amount to be calculated automatically, so that I don't have to multiply quantity by price by hand.

Acceptance Criteria:
- Net Amount = Order Quantity × Net Price, recalculated whenever quantity or price changes.
- Net Price defaults from the Product Master when a product is selected, but can be manually overridden.

**C2 — Automatic Tax Calculation** · *Determination*
> As a **Finance Controller**, I want tax to be derived automatically from the product's tax code, so that tax is always calculated consistently.

Acceptance Criteria:
- Tax Code defaults from the Product Master.
- Tax Amount is recalculated whenever Net Amount or Tax Code changes.

**C3 — Automatic Item-Level USD Conversion** · *Determination*
> As a **Global Sales Manager**, I want every order item's amount automatically converted to USD, so that I can compare and total order values across countries consistently.

Acceptance Criteria:
- On item save, Net Amount and Tax Amount (captured in local currency) are converted to USD using the exchange rate valid on the order date.
- If no valid exchange rate exists for that currency and date, the save is blocked.

**C4 — Automatic Header Total Roll-Up** · *Determination*
> As a **Sales Manager**, I want the order header to always reflect the current total across all items, so that I can see an order's true value at a glance, in USD.

Acceptance Criteria:
- Header Net Amount / Tax Amount / Total Amount are recalculated as the sum across all items, in USD.
- Totals update within the same save/draft cycle as the item change.

**C5 — Customer Credit Limit in USD** · *Determination*
> As a **Credit Controller**, I want customer credit limits automatically converted to USD, so that credit checks are performed on a like-for-like basis regardless of the customer's local currency.

Acceptance Criteria:
- Customer's local Credit Limit is converted to USD and used as the basis for the credit limit validation on the order header.

### Epic D — Delivery Planning

**D1 — Delivery Date Derivation** · *Determination*
> As a **Sales Representative**, I want the delivery date to be handled consistently, so that I don't record delivery promises the warehouse can't meet.

Acceptance Criteria:
- Requested Delivery Date must be at least 7 days after the Order Date.
- Requested Delivery Date cannot be in the past.

### Epic E — Status Lifecycle

**E1 — Initial Status Assignment** · *Determination*
> As a **Sales Rep / Warehouse Coordinator**, I want every new order and item to start in a well-defined status, so that everyone downstream knows where it stands from the start.

Acceptance Criteria:
- New orders default to overall status **New (NW)**.
- New items default to item status **Open**.

**E2 — Order Lifecycle Actions** · *Action*
> As a **Sales Manager**, I want to move an order through Release, Reject, Cancel, or Complete, so that its status always reflects where it truly stands in the process.

Acceptance Criteria:
- Header actions: Release Order, Reject Order, Cancel Order, Complete Order.
- Item actions: Confirm Item, Cancel Item, Deliver Item.
- Actions are only enabled where appropriate for the current status.

### Epic F — Customer Data Integrity

**F1 — Customer Existence & Active Check** · *Validation*
> As a **Sales Manager**, I want the system to block orders for a customer that doesn't exist or is blocked, so that we never invoice a non-existent or blocked account.

Acceptance Criteria:
- On save, Customer ID must exist and be active, otherwise the save is blocked with a clear error.

**F2 — Credit Limit Validation** · *Validation*
> As a **Credit Controller**, I want the system to stop an order that would push a customer over their credit limit (in USD), so that the company doesn't take on avoidable credit risk.

Acceptance Criteria:
- On save, the system checks the order's USD total against the customer's USD credit limit.
- If exceeded, the save is blocked, and the error states the limit and the amount it's exceeded by.

### Epic G — Product Data Integrity

**G1 — Product Existence & Active Check** · *Validation*
> As a **Sales Representative**, I want to be prevented from adding a discontinued or non-existent product, so that orders never contain unsellable items.

Acceptance Criteria:
- On save, each item's Product ID must exist and be active, otherwise the save is blocked with an item-specific error.

**G2 — Stock Availability Validation** · *Validation*
> As a **Warehouse Coordinator**, I want the system to prevent orders for more quantity than is in stock, so that we don't over-promise deliveries.

Acceptance Criteria:
- On save, Order Quantity per item must not exceed the product's Stock Quantity.
- If exceeded, the error shows requested vs. available quantity.

### Epic H — Order Data Quality

**H1 — Quantity & Mandatory Field Validation** · *Validation*
> As a **Sales Representative**, I want to be told immediately if I miss a required field or enter an invalid quantity, so that I catch mistakes before they become a saved order.

Acceptance Criteria:
- Order Quantity must be greater than zero.
- Customer ID must not be blank.

**H2 — Duplicate Item Prevention** · *Validation*
> As a **Sales Representative**, I want to be warned if I accidentally add the same product twice, so that I merge quantities instead of creating confusing duplicate lines.

Acceptance Criteria:
- On save, if the same Product ID appears on more than one item within the same order, the save is blocked.

---

## 8. RAP Artifact Mapping

| # | Story | RAP Artifact | Type | Entity |
|---|---|---|---|---|
| A1 | Order Numbering | `determineOrderID` | Determination | Header |
| B1 | Country Name Derivation | `DeriveCountryName` | Determination | Country |
| B2 | Exchange Rate Defaults | `SetDefaults` | Determination | Exchange Rate |
| B2 | Exchange Rate Overlap Prevention | `CheckOverlap` | Determination | Exchange Rate |
| B2 | Currency Exists Check | `ValidateCurrencyExists` | Validation | Exchange Rate |
| B2 | Positive Rate Check | `ValidatePositiveRate` | Validation | Exchange Rate |
| B2 | Date Range Check | `ValidateDateRange` | Validation | Exchange Rate |
| B2 | Overlap Validation | `ValidateOverlap` | Validation | Exchange Rate |
| B3 | Customer Currency Derivation | `setCurrency` | Determination | Customer |
| C1 | Item Net Amount | `calculateItemAmount` | Determination | Item |
| C2 | Item Tax Amount | `calculateItemTax` | Determination | Item |
| C3 | Item USD Conversion | `convertItemAmountToUSD` | Determination | Item |
| C3 | Exchange Rate Availability Check | `validateExchangeRateAvailable` | Validation | Header |
| C4 | Header Totals | `calculateHeaderTotals` | Determination | Item |
| C5 | Credit Limit USD Conversion | `deriveCustomerCreditLimitUSD` | Determination | Header |
| D1 | Delivery Date Check | `validate_delivery_date` | Validation | Item |
| E1 | Initial Order Status | `setInitialOrderStatus` | Determination | Header |
| E1 | Initial Item Status | `setInitialItemStatus` | Determination | Item |
| F1 | Customer Check | `validateCustomer` | Validation | Header |
| F2 | Credit Limit Check | `validateCreditLimit` | Validation | Header |
| G1 | Product Check | `validateProduct` | Validation | Item |
| G2 | Stock Check | `validateStock` | Validation | Item |
| H1 | Quantity Validation | `validateQuantity` | Validation | Item |
| H2 | Duplicate Item Check | `validateDuplicateProduct` | Validation | Header |

---

## 9. Known Limitations

- A dedicated currency conversion CDS view (`ZI_SO_ITEM_CONV`) and an auxiliary number-range class (`ZCL_AUXILIARY_NRO`) were attempted during development but are not functional in the delivered version — currency conversion is instead handled directly within item-level determination logic.
- Exchange rates are maintained manually; there is no live rate feed integration.
- Built and tested on SAP BTP ABAP Environment Trial only.

---

## 10. Roadmap / Future Enhancements

- Approval workflow for orders above a certain USD threshold
- Analytical KPI cards (Open Order Value, Orders at Risk of Exceeding Credit Limit, Exposure by Country)
- BAdI-based extensibility for credit limit and tax logic, so different regions can inject their own rules
- CDS view extensions to add fields to the projection layer non-invasively
- Live exchange rate feed integration
- ABAP Unit tests using the CDS Test Double Framework


