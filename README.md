<div align="center">

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:101B2D,100:173B4A&height=195&section=header&text=ADVENTUREWORKS%20SQL&fontSize=35&fontColor=F2F6FC&fontAlignY=40&desc=BUSINESS%20INTELLIGENCE%20%7C%20T-SQL%20%7C%20REPORTING&descSize=14&descAlignY=67&descColor=62D6C5" width="100%" alt="AdventureWorks SQL — Business Intelligence, T-SQL, Reporting" />

<p>
  <img src="https://img.shields.io/badge/SQL%20Server-T--SQL-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white" alt="SQL Server T-SQL" />
  <img src="https://img.shields.io/badge/Workflow-Explore%20%7C%20Analyze%20%7C%20Report-0D9488?style=flat-square" alt="Explore, analyze, report" />
  <img src="https://img.shields.io/badge/License-MIT-64748B?style=flat-square" alt="MIT License" />
</p>

**Turning business questions into reusable SQL reporting.**

*A SQL-only analysis of sales trends, customer behavior, and product performance.*

</div>

---

## 01 · Project overview

This project explores the AdventureWorks dataset, a fictional bicycle manufacturer and retailer, using T-SQL. It covers the main stages of a business intelligence workflow, from schema exploration and analytical queries to reusable reporting views.

<table>
  <tr>
    <td align="center" width="33%">
      <h3>01</h3>
      <strong>EXPLORE</strong><br/>
      <sub>Understand tables, dimensions, dates, and measures.</sub>
    </td>
    <td align="center" width="33%">
      <h3>02</h3>
      <strong>ANALYZE</strong><br/>
      <sub>Investigate trends, rankings, performance, and segments.</sub>
    </td>
    <td align="center" width="33%">
      <h3>03</h3>
      <strong>REPORT</strong><br/>
      <sub>Package findings into reusable customer and product views.</sub>
    </td>
  </tr>
</table>

> **Project principle**
>
> Every analysis and reporting view is written in T-SQL. No external BI tool, notebook, or scripting language is used in the workflow.

<details>
<summary><strong>Project scope</strong></summary>

- **Source:** Microsoft AdventureWorks — a fictional company, Adventure Works Cycles
- **Domain:** Bicycle manufacturing and retail
- **Focus:** Products, customers, and sales transactions across multiple years

</details>

## 02 · Data model

The analysis uses a small star schema: one fact table, `gold.fact_sales`, surrounded by the `gold.dim_customers` and `gold.dim_products` dimension tables. Two reporting views, `gold.report_customers` and `gold.report_products`, sit on top of that schema.

<div align="center">

<img src="./docs/erd.svg" alt="AdventureWorks SQL entity relationship diagram" width="100%" />

<sub>Entity relationship diagram · Core analytical tables and relationships</sub>

</div>

Full column-level definitions and business rules—including segmentation thresholds, age groups, and derived metrics—are documented in the [data dictionary](./docs/data_dictionary.md).

## 03 · Business questions

The project uses SQL to answer questions that matter for sales and customer analysis.

<table>
  <tr>
    <th align="center">#</th>
    <th>Business question</th>
    <th>Analysis</th>
  </tr>
  <tr>
    <td align="center"><strong>01</strong></td>
    <td>For each product, how do this year's sales compare with its historical average and last year's results?</td>
    <td><a href="./scripts/02_analysis/09_performance_analysis.sql">Performance analysis</a></td>
  </tr>
  <tr>
    <td align="center"><strong>02</strong></td>
    <td>How do cumulative sales and average prices evolve over time?</td>
    <td><a href="./scripts/02_analysis/08_cumulative_analysis.sql">Cumulative analysis</a></td>
  </tr>
  <tr>
    <td align="center"><strong>03</strong></td>
    <td>How many customers are VIP, Regular, or New based on spending and loyalty?</td>
    <td><a href="./scripts/02_analysis/10_data_segmentation.sql">Customer segmentation</a></td>
  </tr>
  <tr>
    <td align="center"><strong>04</strong></td>
    <td>What does each customer's behavioral and demographic profile look like?</td>
    <td><a href="./scripts/03_reports/12_report_customers.sql">Customer report</a></td>
  </tr>
  <tr>
    <td align="center"><strong>05</strong></td>
    <td>Which countries show unusually high purchasing intensity relative to their customer base?</td>
    <td><a href="./scripts/02_analysis/06_ranking_analysis.sql">Ranking analysis</a></td>
  </tr>
  <tr>
    <td align="center"><strong>06</strong></td>
    <td>Which product categories generate revenue disproportionately high relative to their share of the catalog?</td>
    <td><a href="./scripts/02_analysis/11_part_to_whole_analysis.sql">Part-to-whole analysis</a></td>
  </tr>
</table>

## 04 · SQL techniques

<table>
  <tr>
    <td width="50%">
      <h3>Query design</h3>
      <ul>
        <li>Common Table Expressions (CTEs)</li>
        <li>Window functions: <code>RANK()</code>, <code>LAG()</code></li>
        <li>Running totals and moving averages</li>
      </ul>
    </td>
    <td width="50%">
      <h3>Business logic</h3>
      <ul>
        <li><code>CASE WHEN</code> segmentation and classification</li>
        <li>Date functions for time-based analysis</li>
        <li>Defensive division using <code>NULLIF</code> and zero guards</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>Analytical patterns</h3>
      <ul>
        <li>Magnitude and ranking analysis</li>
        <li>Change-over-time and cumulative analysis</li>
        <li>Performance and part-to-whole comparisons</li>
      </ul>
    </td>
    <td width="50%">
      <h3>Reporting layer</h3>
      <ul>
        <li>Reusable views created with <code>CREATE VIEW</code></li>
        <li>Customer and product reporting tables</li>
        <li>Documented business rules and metric definitions</li>
      </ul>
    </td>
  </tr>
</table>

## 05 · Repository map

<details>
<summary><strong>Browse the SQL scripts and supporting files</strong></summary>

```text
adventureworks-sql-analysis/
├── docs/
│   ├── erd.svg
│   └── data_dictionary.md
├── scripts/
│   ├── 01_exploratory/
│   │   ├── 01_database_exploration.sql
│   │   ├── 02_dimensions_exploration.sql
│   │   ├── 03_date_range_exploration.sql
│   │   └── 04_measures_exploration.sql
│   ├── 02_analysis/
│   │   ├── 05_magnitude_analysis.sql
│   │   ├── 06_ranking_analysis.sql
│   │   ├── 07_change_over_time_analysis.sql
│   │   ├── 08_cumulative_analysis.sql
│   │   ├── 09_performance_analysis.sql
│   │   ├── 10_data_segmentation.sql
│   │   └── 11_part_to_whole_analysis.sql
│   └── 03_reports/
│       ├── 12_report_customers.sql
│       └── 13_report_products.sql
├── LICENSE
└── README.md
```

</details>

## 06 · How to run

<ol>
  <li><strong>Prepare the database.</strong> Restore AdventureWorks on SQL Server, or adapt the <code>gold</code> schema references to your own equivalent star schema.</li>
  <li><strong>Run scripts in order.</strong> Execute <code>01_exploratory</code>, then <code>02_analysis</code>, then <code>03_reports</code>. Within each folder, follow numeric filename order.</li>
  <li><strong>Query the reporting views.</strong> The final scripts create <code>gold.report_customers</code> and <code>gold.report_products</code> for consolidated, reusable reporting.</li>
</ol>

## 07 · Known limitations

<details>
<summary><strong>Read implementation trade-offs and caveats</strong></summary>

- Customer-segmentation `CASE` logic is duplicated between `10_data_segmentation.sql` and `12_report_customers.sql` rather than centralized in a scalar function. This keeps each script self-contained, but the thresholds need to be maintained in both places if they change.
- All monetary values are treated as a single currency; the dataset carries no currency code.
- Recency, age, and lifespan figures are computed relative to `GETDATE()`, so they change over time rather than using a fixed reporting date.

</details>

## 08 · About this project

I built this project to move beyond tutorial-style SQL exercises and practice the kind of structured, business-driven thinking that real data analysis requires. Rather than jumping straight to complex queries, I followed a three-stage workflow—explore the schema, analyze patterns, then package the findings into reusable reporting views—because that discipline is what separates a collection of scripts from an actual analysis.

The most challenging (and valuable) part was translating broad business questions into precise, defensible logic: deciding what makes a customer “VIP” versus “Regular,” or what threshold separates a “High-Performer” product from the rest. Those decisions required me to think like a stakeholder, not just a query writer, and to document assumptions so the logic could be reviewed and challenged.

If I continued this project, I'd add a lightweight data-quality test suite—checking for orphaned foreign keys, negative sales amounts, and duplicate order lines—and wrap the reporting-view refresh in a scheduled stored procedure.

---

<div align="center">

**Parnaz Ali**

[GitHub profile](https://github.com/ParnazAli)

<sub>Released under the MIT License · See <a href="./LICENSE">LICENSE</a> for details.</sub>

</div>
