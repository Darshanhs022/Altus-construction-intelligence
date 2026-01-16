Altus 2.0 – SQL Analytics Layer

Purpose
This document defines the database schema, analytical logic, and view layering strategy for Altus 2.0.
All execution tracking, aggregation, and analytics are implemented in PostgreSQL using a layered SQL-view architecture.

The SQL layer acts as the computation engine of the system and is the single source of truth for all analytics.

1. Physical Tables (Raw Data Layer)

Purpose
This layer stores raw execution facts and reference data only.
No KPIs, percentages, or derived analytics are calculated at table level.

Tables

projects
Stores project-level master data and lifecycle dates.

towers
Defines towers within a project and their total scope.

tower_floor_units
Defines floor-level execution scope using unit counts.

activities_master
Standard list of construction activities and dependencies.

contractors
Contractor master data.

contractor_activity_map
Maps contractor responsibility by project, tower, and activity.

baseline_progress
Stores cumulative execution completed before system cut-in.

raw_progress_input
Stores daily incremental progress events.

mcp_dates
Stores planned milestone dates for schedule comparison.

monthly_planned_units
Stores monthly planned execution targets.

Rules
Tables store facts only
No derived metrics are persisted
Historical data is never overwritten
Corrections are handled via controlled inserts or flags

2. Core Views (Canonical Execution Layer)

File: 02_core_views.sql

Purpose
Core views normalize raw inputs and establish a single canonical execution state for the system.

They handle:
Baseline + daily data unification
Scope capping
Completion detection

Views
vw_all_progress
Normalizes baseline and daily progress into a single event stream
with consistent timestamps.

calc_floor_activity_progress
Calculates floor-level completion ratios by capping cumulative
progress against defined execution scope.

vw_overall_floor_completion
Determines floor completion status based on completion ratios.

vw_structure_actual_floor_completion
Filters structure activity to derive actual floor completion dates.


3. Aggregation Views (Rollup Layer)

File: 03_aggregation_views.sql

Purpose
This layer provides pre-aggregated rollups to simplify downstream analytics and reduce query complexity.

Views
vw_overall_total_units
Calculates total execution scope by tower and activity.

vw_finishing_total_units
Filters total units for finishing activities.

vw_overall_completed_units
Aggregates completed units and floors across progress events.

vw_finishing_completed_units
Filters completed units for finishing activities.

vw_tower_structure_progress
Aggregates structure progress at tower level.

vw_tower_finishing_activity_progress
Aggregates finishing activity progress by tower and activity.

vw_tower_activity_progress_all
Combines structure and finishing activity progress into a unified view.


They exist to:
Simplify analysis logic
Improve performance
Ensure consistency

4. Analysis Views (Insight & Diagnostics Layer)

File: 04_analysis_views.sql

Purpose
This layer introduces analytical intelligence using window functions, comparisons, and time-based logic.

Views
vw_structure_slab_cycle_analysis
Uses window functions to calculate inter-floor slab cycle times
and classify productivity.

vw_structure_mcp_vs_actual
Compares planned milestone dates against actual completion dates.

vw_analysis_date
Derives a system-wide as-of date for time-based analysis.

vw_tower_activity_stagnation
Detects activities with no recent progress using the as-of date.

vw_tower_activity_bottleneck
Identifies lagging activities by comparing activity completion
against tower averages.

vw_project_activity_critical_lag
Detects project-level activities significantly behind average performance.

Rules
Analysis views assume clean canonical data
Time-based logic relies on vw_analysis_date
Baseline records are excluded where analytically invalid

5. Plan vs Actual Views

File: 05_plan_vs_actual_views.sql

Purpose
This layer enables planning discipline without interfering with execution logic.

Views
vw_monthly_actual_units
Aggregates achieved units by project, tower, activity, and month.

vw_activity_monthly_plan_vs_actual
Compares monthly planned targets with achieved execution to calculate:
Variance
Achievement percentage

Rules
Monthly plans do not affect cumulative execution
Absence of plan disables plan-vs-actual analysis only
Execution tracking remains unaffected

6. Semantic Views (BI Contract Layer)
File: 06_semantic_views.sql

Purpose
Semantic views act as stable business contracts for dashboards, reports, and external analytics tools.
They hide internal complexity and expose business-meaningful metrics only.

Views
vw_tower_progress_summary

vw_structure_slab_cycle_analysis

vw_tower_activity_progress_all

vw_tower_activity_stagnation

vw_tower_activity_bottleneck

vw_project_activity_critical_lag

vw_activity_monthly_plan_vs_actual

vw_structure_mcp_vs_actual

Consumption Rules


Semantic views are backward-compatible by design

7. Design Principles
Tables store raw execution facts
Views perform all computation
Logic is layered, not duplicated
Historical data is immutable
Analytics correctness > convenience

Design Summary
Physical layer → raw facts
Core views → canonical execution
Aggregation views → simplified rollups
Analysis views → insights and diagnostics
Semantic views → stable business contracts
