# Altus
SQL-centric construction execution intelligence platform with Python ETL, standardized data contracts, and BI-ready analytics. Designed for scalable, multi-project deployment and future AI/ML integration

This repository is organized to clearly separate **inputs**, **processing**, **analytics logic**, and **consumption**.

### 1. Data Contracts (Inputs)
📄 `Docs/data_contracts.md`  
Defines required inputs, baseline rules, activity structure, planning data, and analytics validity.
Start here to understand **what data the system expects**.

### 2. Excel Templates
📁 `Templates/`  
- `project_onboarding.xlsx` – project, tower, floor, activity setup  
- `monthly_planned_targets.xlsx` – month-wise planned execution  
These templates align directly with the data contracts.

### 3. Python ETL (Ingestion)
📁 `ETL/`  
Handles controlled ingestion, validation, and normalization of onboarding and planning data.
Python is intentionally kept **thin**; no analytical logic lives here.

### 4. SQL Schema (Raw Data)
📄 `SQL/01_schema.sql`  
Defines core tables, raw progress inputs, baseline data, and constraints.
This layer represents the **single source of truth**.

### 5. SQL Views (Analytics Logic)
📁 `SQL/`  
- `02_core_views.sql` – unified progress event stream  
- `03_aggregation_views.sql` – floor, tower, activity aggregations  
- `04_analysis_views.sql` – bottlenecks, stagnation, slab cycles, schedule  
- `05_plan_vs_actual_views.sql` – monthly plan vs actual analysis  
- `06_semantic_views.sql` – BI-ready semantic views  
Most analytical intelligence lives in SQL.

### 6. Power BI (Consumption)
📁 `BI/Dashboards/`  
Dashboards built on semantic SQL views only.
BI acts as a **read-only consumption layer**.

### 7. Architecture & Data Model
📁 `Docs/architecture/`  
- `altus_2.0_architecture.png` – end-to-end data flow  
- `altus_2.0_data_model.png` – high-level entity relationships  
