# Altus 2.0 – Data Contracts

## 1. Project Onboarding

Purpose:
This section defines the minimum static information required to onboard a construction project into Altus 2.0 in a standardised and repeatable manner.

Required Fields:
- Project Name  
- Project Code / Identifier  
- Location  
- Project Type (e.g., high-rise residential, commercial, villa – extensible)  
- Project Start Date (actual site start date)  
- System Cut-in Date (date from which Altus starts tracking daily progress)  
- Project Status (ongoing / completed / on-hold)

Cut-in Date Definition:
The cut-in date represents the point at which the Altus system becomes active for the project.
- For new projects, the cut-in date may match the project start date.
- For already running projects, the cut-in date will be later than the project start date.


Baseline Rule:
For projects that started before the cut-in date:
- Completed work up to the cut-in date is recorded as baseline progress.
- Baseline entries represent total completion till that date.
- Baseline records are flagged distinctly from daily progress entries.
- Baseline entries do not distort cumulative logic or trend analysis.

Assumptions:
- All project master data is provided before any daily progress input begins.
- Project identifiers remain immutable after onboarding.
- Changes to project-level static data require controlled updates and versioning.

Outcome:
Once onboarding is completed, the project becomes eligible for:
- Daily progress and labour input
- Automated validation and processing
- Reporting, analytics, and dashboarding

## 2. Tower & Floor Structure

Purpose:
This section defines how physical building structure is represented in Altus to enable accurate scope, progress tracking, and analytics.

Required Entities:
- Tower
- Floor
- Units per floor

Required Fields (Tower Level):
- Project Identifier
- Tower Name / Code
- Total Number of Floors
- Floor Typology (e.g., podium, typical floors, terrace – optional and extensible)

Required Fields (Floor Level):
- Tower Identifier
- Floor Level (numeric, increasing from bottom to top)
- Number of Units on the Floor

Rules:
- Every tower must be fully defined before progress tracking begins.
- Each floor within a tower must have an explicit unit count.
- Floor levels must be consistent and continuous within a tower.
- Unit count per floor is immutable once progress tracking starts.

Assumptions:
- Unit counts represent execution scope for structure and finishing activities.
- Floor-level unit definition is mandatory even if some activities are tracked only at floor level.
- Any change to tower or floor structure after onboarding requires controlled correction and audit.

Outcome:
The tower and floor structure serves as the foundation for:
- Scope calculation
- Cumulative progress logic
- MCP comparison
- Delay, bottleneck, and productivity analysis

## 3. Activities Master

Purpose:
This section defines the standard list of construction activities tracked by Altus and the rules governing their behaviour, dependencies, and measurement.

Required Fields:
- Activity Name (unique, standardised)
- Activity Category (structure / finishing / other – extensible)
- Measurement Unit (units / floors)
- Dependency Activity (if applicable)
- Active Flag (to allow future deactivation without data loss)

Rules:
- Activity names must be standardised and consistent across all projects.
- Each activity must belong to a category to enable grouped analysis.
- Measurement unit defines how progress is interpreted and aggregated.
- Dependency activity defines prerequisite completion required for scope availability.
- Activities can be added mid-project without affecting historical data.
- Deactivated activities remain in the system for audit and historical reporting.

Assumptions:
- Dependencies represent logical execution order, not contractual constraints.
- Dependency rules are used for scope, pending, and bottleneck analysis.
- Activities are reused across projects wherever applicable.

Outcome:
The activities master enables:
- Consistent progress capture
- Dependency-based scope and pending calculations
- Cross-project and cross-activity analytics

## 4. Contractors Master

Purpose:
This section defines how contractors are represented within Altus to enable attribution, performance analysis, and accountability.

Required Fields:
- Contractor Name (unique)
- Contractor Type (e.g., structure, finishing, MEP – extensible)
- Active Flag
- Optional Remarks

Rules:
- Contractor names must be standardised and unique.
- Contractors can be shared across multiple projects.
- Active flag controls current participation without deleting historical data.
- Deactivated contractors remain available for historical reporting and audits.

Assumptions:
- Contractor information is onboarded before progress or labour data is recorded.
- Contractor changes during a project are handled through mapping validity periods, not by modifying historical records.

Outcome:
The contractors master enables:
- Contractor-wise progress tracking
- Productivity and performance analysis
- Risk identification and accountability

## 5. Contractor–Activity–Tower Mapping

Purpose:
This section defines which contractor is responsible for which activity in which tower, enabling accurate attribution, analysis, and operational clarity.

Required Fields:
- Project Identifier
- Tower Identifier
- Activity Name
- Contractor Name
- Effective From Date
- Effective To Date (nullable for current assignment)
- Active Flag

Rules:
- Every activity executed in a tower must have an associated contractor mapping.
- Multiple contractors can be assigned to the same activity across different towers.
- Contractor changes during execution are handled by closing the previous mapping (Effective To Date) and creating a new one.
- Historical mappings must never be overwritten or deleted.

Assumptions:
- Mapping represents execution responsibility, not contractual scope.
- At any given date, only one active contractor mapping exists per tower–activity combination.
- Labour and progress data inherit contractor attribution from this mapping when not explicitly provided.

Outcome:
This mapping enables:
- Contractor-wise progress and labour analytics
- Accurate productivity calculations
- Risk, delay, and accountability analysis

## 6. Baseline / Cut-in Rules

Purpose:
This section defines how Altus 2.0 handles projects that are already in progress at the time of system deployment, ensuring continuity without corrupting analytics.

Definitions:
- Cut-in Date: The date from which Altus starts recording daily progress inputs.
- Baseline Progress: Aggregated completion achieved before the cut-in date.

Baseline Rules:
- For projects started before the cut-in date, baseline progress must be recorded once during onboarding.
- Baseline entries represent total completed scope up to the cut-in date.
- Baseline data can be provided at floor-level and/or unit-level as applicable.
- Baseline records are inserted into the same progress tables as regular data but flagged distinctly.

Technical Handling:
- Baseline records are marked using a baseline indicator flag.
- Baseline records use the cut-in date as the recorded completion date.
- Baseline entries are excluded from:
  - daily velocity calculations
  - trend analysis
  - productivity baselines
- Baseline entries are included in:
  - cumulative completion
  - pending scope calculations

Rules for Missing Historical Granularity:
- If exact historical dates are unavailable, baseline data is treated as a single consolidated entry.
- No artificial back-dating or synthetic daily records are created.

Assumptions:
- Baseline data is provided only once per activity–tower–floor combination.
- After cut-in, all progress must be captured through daily inputs only.

Outcome:
Baseline handling ensures that:
- Ongoing projects can be onboarded safely
- Cumulative progress remains accurate
- Analytical integrity is preserved

## 7. Daily Progress Input

Purpose:
This section defines the minimal daily progress data captured from site engineers to track execution accurately without increasing reporting burden.

Required Fields:
- Project Identifier
- Entry Date
- Tower Identifier
- Floor Level
- Activity Name
- Units Completed (for the day)
- Optional Status / Remarks

Rules:
- Daily entries capture incremental progress, not cumulative totals.
- Multiple entries on the same day are allowed.
- Units completed cannot exceed remaining available scope for that floor and activity.
- Negative or decreasing progress entries are not permitted.
- Activity names must match the Activities Master.

Validation Logic:
- Units are automatically capped based on defined floor scope.
- Invalid entries are rejected and logged with reason.
- Progress beyond full completion is ignored and audited.

Assumptions:
- Site engineers enter only what is physically completed on that day.
- Engineers are not required to calculate totals or percentages.
- All dependency, scope, and cumulative logic is handled by the system.

Outcome:
Daily progress input enables:
- Accurate cumulative tracking
- Real-time visibility of execution status
- Automated identification of delays and bottlenecks

## 8. Analytics Validity Rules

Purpose:
This section defines which analyses are valid based on data availability and project lifecycle stage.

Validity Rules:
- Cumulative completion and pending scope analysis are always valid once baseline is established.
- MCP vs actual analysis is valid only where planned dates are available.
- Velocity and trend analysis are valid only for post cut-in daily data.
- Productivity analysis requires both progress and labour data.
- Contractor performance analysis requires active contractor mappings.

Exclusions:
- Baseline records are excluded from:
  - velocity calculations
  - trend analysis
  - productivity baselines
- Inactive activities are excluded from lag and bottleneck classification.

Assumptions:
- Analytics maturity increases over time as data volume grows.
- Early-stage dashboards prioritise visibility over prediction.

Outcome:
These rules ensure that:
- Insights remain reliable and interpretable
- Dashboards do not misrepresent incomplete data
- Advanced analytics can be layered safely in future phases

## 9. Monthly Planned Targets

Purpose:
Defines how monthly planned scope is captured to enable plan vs actual analysis without affecting daily execution logic.

Required Fields:
- Project Identifier
- Tower Identifier
- Activity Name
- Plan Month (DATE, first day of month)
- Planned Units

Rules:
- One record per project–tower–activity–month
- Plan Month must be stored as the first calendar day of the month
- Example: 2026-02-01 represents February 2026
- Planned units represent expected execution for that month, not cumulative totals
- Monthly plans can be uploaded:
  - before the month starts
  - or mid-month (updates allowed)
Re-uploads for the same month overwrite the plan, not append

Technical Handling:
- Monthly plans are stored in a dedicated table
- Inserts use upsert logic (idempotent by month)
- Historical months are never deleted automatically
- Plans do not affect:
  - baseline logic
  - cumulative completion
  - daily progress calculations

Assumptions:
- Planning data may change during the month
- Monthly planning maturity improves over time
- Absence of a monthly plan means:
  - plan vs actual analysis is unavailable
  - progress tracking remains valid

Outcome:
- Monthly planned targets enable:
  - Plan vs actual reporting
  - Variance and forecast analysis
  - Schedule discipline without corrupting execution data


## Architecture Overview

The diagram below shows the high-level data flow in ALTUS 2.0,
from data ingestion to analytical outputs.

![ALTUS 2.0 Architecture](Docs/altus_2.0_architecture.png)




