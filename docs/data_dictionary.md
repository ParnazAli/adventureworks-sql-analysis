# Data Dictionary & Business Rules

This document defines every business rule and derived field used across the
project, so the segmentation logic in `10_data_segmentation.sql`,
`12_report_customers.sql`, and `13_report_products.sql` can be read (and
challenged) without reverse-engineering the SQL.

## Source Tables (gold layer)

| Table                | Grain                  | Key Columns |
|-----------------------|-------------------------|-------------|
| `gold.dim_customers`  | One row per customer   | `customer_key` (PK), `customer_number`, `first_name`, `last_name`, `birthdate`, `gender`, `country` |
| `gold.dim_products`   | One row per product    | `product_key` (PK), `product_name`, `category`, `subcategory`, `cost` |
| `gold.fact_sales`     | One row per order line | `order_number`, `order_date`, `customer_key` (FK), `product_key` (FK), `sales_amount`, `quantity`, `price` |

See [`erd.svg`](./erd.svg) for the visual relationship diagram.

## Customer Segmentation

Used in: `10_data_segmentation.sql`, `12_report_customers.sql`

| Segment   | Rule |
|-----------|------|
| **VIP**     | `lifespan >= 12 months` **and** `total_sales > 5000` |
| **Regular** | `lifespan >= 12 months` **and** `total_sales <= 5000` |
| **New**     | `lifespan < 12 months` (regardless of spend) |

- `lifespan` = months between a customer's first and last order.
- A customer must be active for at least a year before they can be
  considered "loyal" (VIP or Regular) — a big first purchase alone does
  not qualify someone as VIP.

## Product Segmentation

Used in: `13_report_products.sql`

| Segment           | Rule |
|--------------------|------|
| **High-Performer**  | `total_sales > 50,000` |
| **Mid-Range**       | `10,000 <= total_sales <= 50,000` |
| **Low-Performer**   | `total_sales < 10,000` |

## Product Cost Ranges

Used in: `10_data_segmentation.sql`

| Range        | Rule |
|--------------|------|
| Below 100    | `cost < 100` |
| 100–500      | `100 <= cost <= 500` |
| 500–1000     | `500 <= cost <= 1000` |
| Above 1000   | `cost > 1000` |

## Age Groups

Used in: `12_report_customers.sql`

| Group        | Rule |
|--------------|------|
| Under 20     | `age < 20` |
| 20–29        | `20 <= age <= 29` |
| 30–39        | `30 <= age <= 39` |
| 40–49        | `40 <= age <= 49` |
| 50 and above | `age >= 50` |

## Derived Metrics Glossary

| Metric               | Formula |
|------------------------|---------|
| `lifespan`              | Months between first and last order/sale |
| `recency` / `recency_in_months` | Months since the last order/sale, relative to `GETDATE()` |
| `avg_order_value` / `avg_order_revenue` | `total_sales / total_orders` |
| `avg_monthly_spend` / `avg_monthly_revenue` | `total_sales / lifespan` |
| `avg_selling_price`     | Average of (`sales_amount / quantity`) per order line — the realized price, not the list price |
| `revenue_efficiency_ratio` | (category's % of total revenue) / (category's % of total product catalog) |

## Known Assumptions

- All monetary figures are treated as a single, unconverted currency —
  the source dataset does not carry a currency code.
- Rows with a `NULL` `order_date` are excluded from every time-based
  analysis, since they cannot be placed on a timeline.
- `GETDATE()` is used as "today" for all recency/age calculations, so
  age, recency, and lifespan values will naturally drift as time passes
  — they are not frozen to a fixed snapshot date.
