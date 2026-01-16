SQL Layer — ALTUS 2.0

This folder contains the complete database schema and analytics logic for ALTUS 2.0.
All execution tracking, aggregation, and analytical rules are implemented in PostgreSQL using layered SQL views.
The SQL layer acts as the computation engine of the system.


1. Database Tables (Physical Layer)
Tables store raw facts and reference data only.
No KPIs, percentages, or analytics are calculated at table level.


2. SQL Views (Analytics Layer)
Views are organised into clear functional layers.
Each view is defined once and reused downstream.

A).Core Views (02_core_views.sql)
These views establish the canonical execution state.

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


Aggregation Views (03_aggregation_views.sql)
Intermediate rollups used to simplify analytics and reporting.


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


Analysis Views (04_analysis_views.sql)
Advanced analytical and diagnostic logic.


vw_structure_slab_cycle_analysis
Uses window functions to calculate inter-floor slab cycle times
and classify productivity.


vw_structure_mcp_vs_actual
Compares planned milestone dates against actual completion dates.


vw_analysis_date
Derives a system-wide “as-of” date for time-based analysis.


vw_tower_activity_stagnation
Detects activities with no recent progress using an as-of-date reference.


vw_tower_activity_bottleneck
Identifies lagging activities by comparing activity completion
against tower averages.


vw_project_activity_critical_lag
Detects project-level activities significantly behind average performance.


Plan vs Actual Views (05_plan_vs_actual_views.sql)
Planning comparison logic.


vw_monthly_actual_units
Aggregates achieved units by project, tower, activity, and month.


vw_activity_monthly_plan_vs_actual
Compares monthly planned targets with achieved execution to calculate
variance and achievement percentages.


B).Semantic Views (06_semantic_views.sql)
Business-facing, analytics-ready views.

These views act as stable contracts for reporting tools.

vw_tower_progress_summary
vw_structure_slab_cycle_analysis
vw_tower_activity_progress_all
vw_tower_activity_stagnation
vw_tower_activity_bottleneck
vw_project_activity_critical_lag
vw_activity_monthly_plan_vs_actual
vw_structure_mcp_vs_actual


Rules
Reporting tools connect only to semantic views
Core, aggregation, and analysis views are internal computation layers


Design Summary
Tables store raw execution facts
Core views establish canonical progress
Aggregation views simplify calculations
Analysis views generate insights
Semantic views expose stable business definitions