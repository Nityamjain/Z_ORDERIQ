# OrderIQ – Object Schema

Complete technical schema documentation for the OrderIQ RAP application, covering domains, data elements, database tables, CDS entities, behavior definitions, and service artifacts.

---

## 1. Domains

| # | Domain Name | Description |
|---|---|---|
| 1 | `ZACTIVE_FLAG` | Generic active/inactive indicator |
| 2 | `ZAMOUNT` | Monetary amount (price, net, tax, total) |
| 3 | `ZCREDIT_LIMIT` | Customer credit limit |
| 4 | `ZCUST_ID` | Customer number |
| 5 | `ZPROD_ID` | Product number |
| 6 | `ZQUANTITY` | Quantity (order / stock) |
| 7 | `ZSO_HDR_STATUS` | Overall sales order status |
| 8 | `ZSO_ITEM_NO` | Sales order item number, incremented in steps of 10 |
| 9 | `ZSO_ITM_STATUS` | Sales order item status |
| 10 | `ZSO_ORDER_ID` | External sales order number |
| 11 | `ZTAX_CODE` | Tax determination code |

---

## 2. Data Elements

| # | Data Element | Description |
|---|---|---|
| 1 | `ZDE_ACTIVE` | Active |
| 2 | `ZDE_CREDIT_LIMIT` | Credit Limit |
| 3 | `ZDE_CUSTOMER_ID_10` | Customer |
| 4 | `ZDE_NET_AMOUNT` | Net Amount |
| 5 | `ZDE_NET_PRICE` | Net Price |
| 6 | `ZDE_ORDER_QTY` | Order Qty |
| 7 | `ZDE_PRODUCT_ID_10` | Product |
| 8 | `ZDE_SO_HDR_STATUS` | Order Status |
| 9 | `ZDE_SO_ITEM_NO` | Item No. |
| 10 | `ZDE_SO_ITM_STATUS` | Item Status |
| 11 | `ZDE_SO_ORDER_ID` | Sales Order |
| 12 | `ZDE_STOCK_QTY` | Stock Qty |
| 13 | `ZDE_TAX_AMOUNT` | Tax Amount |
| 14 | `ZDE_TAX_CODE` | Tax Code |
| 15 | `ZDE_TOTAL_AMOUNT_10` | Total Amount |

---

## 3. Database Tables

| # | Table Name | Description |
|---|---|---|
| 1 | `ZCUSTOMER_D_MSTR` | Draft table for entity `ZI_CUSTOMER_IQ` |
| 2 | `ZCUSTOMER_MSTR` | Customer Master |
| 3 | `ZPRODUCT_D_MASTR` | Draft table for entity `ZI_PRODUCT_IQ` |
| 4 | `ZPRODUCT_MSTR` | Product Master |
| 5 | `ZSO_COUNTRY` | Master Table for Country |
| 6 | `ZSO_D_COUNTRY` | Draft table for entity `ZI_COUNTRY_IQ` |
| 7 | `ZSO_D_EXCHANGE_R` | Draft table for entity `ZI_EXCHANGE_IQ` |
| 8 | `ZSO_D_HEADER_IQ` | Draft table for entity `ZI_SALESORDER_IQ` |
| 9 | `ZSO_D_ITEM_IQ` | Draft table for entity `ZI_SALESORDERITEM_IQ` |
| 10 | `ZSO_EXCHANGE_R` | Exchange Rate Master |
| 11 | `ZSO_HEADER_IQ` | Sales Order Header |
| 12 | `ZSO_ITEM_IQ` | Sales Order Item |

---

## 4. CDS Data Definitions

| # | Data Definition | Description |
|---|---|---|
| 1 | `ZC_COUNTRY_IQ` | Country Projection |
| 2 | `ZC_CUSTOMER_IQ` | Customer Projection View |
| 3 | `ZC_EXCHANGE_IQ` | Exchange Rate Projection |
| 4 | `ZC_PRODUCT_IQ` | Product Projection |
| 5 | `ZC_SALESORDERITEM_IQ` | Sales Order Item Projection |
| 6 | `ZC_SALESORDER_IQ` | Sales Order Header Projection |
| 7 | `ZI_COUNTRY_IQ` | Country Interface |
| 8 | `ZI_CUSTOMER_IQ` | Customer Interface |
| 9 | `ZI_EXCHANGE_IQ` | Exchange Rate Interface |
| 10 | `ZI_PRODUCT_IQ` | Product Interface |
| 11 | `ZI_SALESORDERITEM_IQ` | Sales Order Item Interface |
| 12 | `ZI_SALESORDER_IQ` | Sales Order Header Interface |
| 13 | `ZVH_ACTIVE_STATUS` | Active Status Value Help |
| 14 | `ZVH_COUNTRY` | Country Value Help |
| 15 | `ZVH_CURRENCY` | Currency Value Help |
| 16 | `ZVH_CUSTOMER` | Customer Value Help |
| 17 | `ZVH_ITEM_STATUS` | Item Status Value Help |
| 18 | `ZVH_ORDER_STATUS` | Order Status Value Help |
| 19 | `ZVH_PRODUCT` | Product Value Help |
| 20 | `ZVH_TAXCODE_IQ` | Tax Code Value Help |

---

## 5. Metadata Extensions

| # | Metadata Extension | Description |
|---|---|---|
| 1 | `ZC_COUNTRY_IQ` | Country Metadata |
| 2 | `ZC_CUSTOMER_IQ` | Customer Metadata |
| 3 | `ZC_EXCHANGE_IQ` | Exchange Rate Metadata |
| 4 | `ZC_PRODUCT_IQ` | Product Metadata |
| 5 | `ZC_SALESORDERITEM_IQ` | Sales Order Item Metadata |
| 6 | `ZC_SALESORDER_IQ` | Sales Order Header Metadata |

---

## 6. Behavior Definitions

| # | Behavior Definition | Description |
|---|---|---|
| 1 | `ZC_COUNTRY_IQ` | Country Projection Behavior |
| 2 | `ZC_CUSTOMER_IQ` | Customer Projection Behavior |
| 3 | `ZC_EXCHANGE_IQ` | Exchange Rate Projection Behavior |
| 4 | `ZC_PRODUCT_IQ` | Product Projection Behavior |
| 5 | `ZC_SALESORDER_IQ` | Sales Order Header Projection Behavior Definition |
| 6 | `ZI_COUNTRY_IQ` | Country Behavior Definition |
| 7 | `ZI_CUSTOMER_IQ` | Customer Behavior Definition |
| 8 | `ZI_EXCHANGE_IQ` | Exchange Rate Behavior Definition |
| 9 | `ZI_PRODUCT_IQ` | Product Behavior Definition |
| 10 | `ZI_SALESORDER_IQ` | Sales Order Header Behavior Definition |

---

## 7. Behavior Implementation Classes

| # | Class Name | Description |
|---|---|---|
| 1 | `ZBP_I_COUNTRY_IQ` | Behavior Implementation for `ZI_COUNTRY_IQ` |
| 2 | `ZBP_I_CUSTOMER_IQ` | Behavior Implementation for `ZI_CUSTOMER_IQ` |
| 3 | `ZBP_I_EXCHANGE_IQ` | Behavior Implementation for `ZI_EXCHANGE_IQ` |
| 4 | `ZBP_I_PRODUCT_IQ` | Behavior Implementation for `ZI_PRODUCT_IQ` |
| 5 | `ZBP_I_SALESORDER_IQ` | Behavior Implementation for `ZI_SALESORDER_IQ` |

---

## 8. Service Artifacts

| Category | Name | Description |
|---|---|---|
| Service Definition | `ZUI_ORDERIQ_O4` | OrderIQ Service |
| Service Binding | `ZUI_ORDERIQ_O4_UI` | OrderIQ Service Binding (OData V4, UI) |
| Message Class | `ZSO_MSG` | Message class for validation/error messages in OrderIQ |

---

## 9. Message Class – ZSO_MSG

| # | Message Text |
|---|---|
| 001 | Customer ID not Found |
| 002 | Customer ID is Inactive |
| 003 | Customer (&1) has exceeded the credit &2 limit by &3 |
| 004 | Product &1 does not exist |
| 005 | Product &1 is inactive |
| 006 | Insufficient stock for product &1. Req: &2, Available: &3 |
| 007 | Order Quantity of &1 must be greater than zero |
| 008 | Product &1 delivery date must be 7 days after order date |
| 009 | Requested Delivery Date cannot be in the past |
| 010 | Customer ID is Mandatory | 
 and more ...

---

## 10. Actions, Determinations & Validations by Entity

| Entity | Actions | Determinations | Validations |
|---|---|---|---|
| **ZI_SalesOrder_IQ** (Header) | Release Order, Reject Order, Cancel Order, Complete Order; Draft: Edit, Resume, Activate, Discard; Prepare | Determine Order ID; Set Initial Order Status; Derive Order Date; Derive Customer Currency; Derive Customer Credit Limit (USD) | Validate Customer; Validate Credit Limit; Validate Duplicate Product; Validate Exchange Rate Available |
| **ZI_SalesOrderItem_IQ** (Item) | Confirm Item, Cancel Item, Deliver Item | Calculate Item Amount; Calculate Item Tax; Calculate Header Totals; Derive Product Data; Derive Delivery Date; Set Initial Item Status; Determine Item Number; Convert Item Amount to USD | Validate Product; Validate Stock; Validate Quantity; Validate Delivery Date |
| **ZI_Exchange_IQ** (Exchange Rate) | Draft: Edit, Resume, Activate, Discard; Prepare | Set Defaults; Check Overlap | Validate Currency Exists; Validate USD Rate; Validate Positive Rate; Validate Date Range; Validate Overlap |
| **ZI_Customer_IQ** (Customer Master) | Draft: Edit, Resume, Activate, Discard; Prepare | Set Currency | — |
| **ZI_Country_IQ** (Country) | Draft: Edit, Resume, Activate, Discard; Prepare | Derive Country Name | — |

---

## 11. Entity Relationships

ZCUSTOMER_MSTR (1) ────< (N) ZSO_HEADER_IQ (1) ────< (N) ZSO_ITEM_IQ (N) >──── (1) ZPRODUCT_MSTR
│
│ (currency lookup)
▼
ZSO_COUNTRY (1) ──── (1) ZSO_EXCHANGE_R

- One **Customer** can have many **Sales Orders**
- One **Sales Order Header** has many **Sales Order Items** (composition — items deleted when header is deleted)
- One **Product** can appear on many **Order Items**
- Each **Country** has one **Currency**, and each **Currency** has a time-bound **Exchange Rate against USD**
