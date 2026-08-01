<img width="1896" height="856" alt="image" src="https://github.com/user-attachments/assets/bf285c7b-0b37-40c0-9b91-8578bb95135d" /># OrderIQ – Intelligent Multi-Currency Sales Order Management

**A RAP (RESTful ABAP Programming Model) reference application built on SAP BTP ABAP Environment, showcasing enterprise-grade order management with automated business logic, multi-country customer/product handling, and real-time USD currency conversion.**

---

## 🎯 Purpose

OrderIQ is an end-to-end Sales Order Management application designed to eliminate manual effort and manual risk from order entry. It allows a business to create and manage customers and products across different countries, raise sales orders in each customer's local currency, and automatically convert every amount to USD using time-bound exchange rate snapshots — giving management a single, consistent, USD-based view of order value regardless of which country or currency the order originated in.

The project was built as a hands-on exploration of RAP's core mechanisms — **Determinations**, **Validations**, and **Actions** — applied to a realistic, enterprise-style order-to-cash scenario.

---

## 💡 Use Case

A distributor sells products to customers located in different countries (US, India, Japan, China, UAE, Switzerland, Kuwait, and more). Each customer has a credit limit in their own local currency. When a sales rep raises an order:

1. The customer and product are selected from master data (with value help).
2. Item pricing is captured in the **product's local currency**.
3. The system automatically converts item amounts to **USD** using the exchange rate valid on that date, for that currency.
4. Header totals (Net, Tax, Total) are rolled up and shown in USD, alongside the customer's credit limit in USD — giving a true apples-to-apples comparison regardless of the order's original currency.
5. Business rules (credit limit, stock, duplicate products, delivery date logic) are enforced automatically before the order can be saved or released.

This mirrors a real enterprise requirement: **global order visibility in a single reporting currency**, without losing the transactional detail in each country's local currency.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Development Environment | ABAP Development Tools (ADT) in Eclipse |
| Platform | SAP BTP ABAP Environment (Trial) |
| Programming Model | RAP (RESTful ABAP Programming Model) — Managed Scenario with Draft Handling |
| Data Modeling | CDS (Core Data Services) |
| Business Logic | ABAP OO, EML (Entity Manipulation Language) |
| Service Layer | OData V4 |
| UI | SAP Fiori Elements (List Report + Object Page) |

---

## ✨ Key Features

- **Multi-entity order management** — Customer Master, Product Master, Country Master, Exchange Rate Master, Sales Order Header, and Sales Order Item
- **Automatic USD currency conversion** at item level, using date-effective exchange rates
- **Time-bound exchange rates** — each rate has a Valid From / Valid To period, with overlap prevention for the same currency
- **Automated business logic** via 15+ Determinations and Validations across all entities
- **Full order lifecycle** with custom actions: Release, Reject, Cancel, Complete (header) and Confirm, Cancel, Deliver (item)
- **Draft handling** throughout — Edit, Resume, Activate, Discard on every business object
- **Value Help (F4)** for Country, Currency, Customer, Product, Tax Code, and status fields
- **Centralized message class** (`ZSO_MSG`) for consistent, parameterized error messages
- **Fiori Elements UI** — List Report + Object Page, with side-by-side local currency and USD columns on order items

---

## 🏗️ Business Objects Created

### Database Tables (10 + 2 draft tables)
| Entity | Active Table | Draft Table |
|---|---|---|
| Customer Master | `ZCUSTOMER_MSTR` | `ZCUSTOMER_D_MSTR` |
| Product Master | `ZPRODUCT_MSTR` | `ZPRODUCT_D_MASTR` |
| Country Master | `ZSO_COUNTRY` | `ZSO_D_COUNTRY` |
| Exchange Rate Master | `ZSO_EXCHANGE_R` | `ZSO_D_EXCHANGE_R` |
| Sales Order Header | `ZSO_HEADER_IQ` | `ZSO_D_HEADER_IQ` |
| Sales Order Item | `ZSO_ITEM_IQ` | `ZSO_D_ITEM_IQ` |

### CDS Layer
- 6 Interface Views (`ZI_*`) and 6 Projection/Consumption Views (`ZC_*`) — one pair per business entity
- 8 Value Help CDS entities (`ZVH_*`) for Country, Currency, Customer, Product, Tax Code, Active Status, Order Status, Item Status
- 6 Metadata Extensions (`ZC_*`) for Fiori Elements UI annotations

### Behavior Layer
- 6 Behavior Definitions (one per business entity)
- 5 Behavior Implementation classes (`ZBP_I_*`)

### Service
- Service Definition: `ZUI_ORDERIQ_O4`
- Service Binding: `ZUI_ORDERIQ_O4_UI` (OData V4, UI)
- Message Class: `ZSO_MSG`

*(Full technical schema with fields, domains, and data elements is available in the [Object Schema](#) document / see repo.)*

---

## ⚙️ Business Logic

### Sales Order Header (`ZI_SalesOrder_IQ`)
- **Actions:** Release Order, Reject Order, Cancel Order, Complete Order
- **Determinations:** Order ID generation, initial order status, order date derivation, customer currency derivation, credit limit conversion to USD
- **Validations:** Customer must exist & be active, credit limit not exceeded, no duplicate products in one order, exchange rate must be available for the order's currency

### Sales Order Item (`ZI_SalesOrderItem_IQ`)
- **Actions:** Confirm Item, Cancel Item, Deliver Item
- **Determinations:** Item amount calculation, tax calculation, header totals roll-up, product data derivation, delivery date derivation, initial item status, item numbering, USD conversion
- **Validations:** Product must exist & be active, sufficient stock, quantity > 0, delivery date must be ≥7 days after order date and not in the past

### Exchange Rate (`ZI_Exchange_iq`)
- **Determinations:** Default value setting, overlap check on save
- **Validations:** Currency must exist, rate against USD must be valid & positive, valid date range, no overlapping validity periods for the same currency

### Customer Master (`ZI_Customer_IQ`)
- **Determinations:** Currency auto-assigned based on customer's country

### Country Master (`ZI_Country_iq`)
- **Determinations:** Country name derivation

---

## 🖥️ UI Highlights

- **List Report + Object Page** (Fiori Elements) for all 6 business objects
- **Draft-enabled** editing with Editing Status filter (All / Draft / Active)
- **Status-driven action enablement** — buttons like Release/Reject/Cancel/Complete are context-aware based on current order status
- **Side-by-side currency display** on order items — local currency (Net Price, Net Amount, Tax Amount) shown alongside converted USD amounts, so users see both the transactional and reporting currency at once
- Object Page for Orders includes an embedded Items table with its own action bar (Confirm / Cancel / Deliver)

---

## 📸 Screenshots

<img width="1896" height="856" alt="image" src="https://github.com/user-attachments/assets/e076c07b-8ff2-4c77-9fa2-291678b7628e" />
<img width="1872" height="898" alt="image" src="https://github.com/user-attachments/assets/dcff4e85-fa80-4dd8-8552-aa19c05a76dd" />
<img width="847" height="701" alt="image" src="https://github.com/user-attachments/assets/99a9f20b-52c0-4367-95f9-7a1195c0ea7a" />
<img width="1915" height="757" alt="image" src="https://github.com/user-attachments/assets/28db00b1-1bc9-414c-9d44-7f2e0e3647cc" />
<img width="1252" height="376" alt="image" src="https://github.com/user-attachments/assets/ea5dd4cd-9b32-4855-ad56-97fa8cc2ad14" />
<img width="1917" height="772" alt="image" src="https://github.com/user-attachments/assets/926c204d-b0ca-4450-9ded-34b7c873eadc" />
<img width="1917" height="481" alt="image" src="https://github.com/user-attachments/assets/51fd3a38-181a-4eb6-a98c-48c47f4b4bb4" />
<img width="1915" height="436" alt="image" src="https://github.com/user-attachments/assets/02d50139-373b-41f1-a164-c89a042d43a1" />













---

## 🚧 Known Limitations / Not Implemented

- Currency conversion CDS (`ZI_SO_ITEM_CONV`) and auxiliary number-range class (`ZCL_AUXILIARY_NRO`) were attempted but not functional in this version
- Built and tested on SAP BTP ABAP Environment Trial only

---

## 🗺️ Roadmap / Future Enhancements

- Approval workflow for orders above a certain USD threshold
- Analytical KPI cards (Open Order Value, Orders at Risk of Exceeding Credit Limit)
- BAdI-based extensibility for credit limit and tax logic
- ABAP Unit tests using the CDS Test Double Framework

---

## 🔗 Repository

[github.com/Nityamjain/Z_ORDERIQ](https://github.com/Nityamjain/Z_ORDERIQ)

---

## 👤 Author

Built by Nityam Jain as a hands-on learning project to master SAP RAP — Determinations, Validations, Actions, and multi-currency business scenarios — on SAP BTP.

## 📄 License

**© 2026 Nityam Jain. All Rights Reserved.**

This project is shared publicly for portfolio and demonstration purposes only. The code, documentation, and associated materials may **not** be copied, modified, distributed, or used — in whole or in part — for personal, academic, or commercial purposes without **prior written permission** from the author.

If you'd like to use, reference, or build upon this project, please reach out via [LinkedIn](#) or [email](#) to request permission.
