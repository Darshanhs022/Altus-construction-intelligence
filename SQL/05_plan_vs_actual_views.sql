create or replace view vw_monthly_actual_units as
select
    project_code,
    tower_name,
    activity_name,
    date_trunc('month', progress_date)::date as plan_month,
    sum(completed_units) as achieved_units
from vw_all_progress
where is_baseline = false
group by
    project_code,
    tower_name,
    activity_name,
    date_trunc('month', progress_date);


create or replace view vw_activity_monthly_plan_vs_actual as
select
    p.project_code,
    p.tower_name,
    p.activity_name,
    p.plan_month,
    p.planned_units,
    coalesce(a.achieved_units, 0) as achieved_units,
    coalesce(a.achieved_units, 0) - p.planned_units as variance_units,
    round(
        coalesce(a.achieved_units, 0)::numeric
        / nullif(p.planned_units, 0) * 100,
        1
    ) as achievement_pct
from monthly_planned_units p
left join vw_monthly_actual_units a
  on a.project_code = p.project_code
 and a.tower_name   = p.tower_name
 and a.activity_name = p.activity_name
 and a.plan_month   = p.plan_month;
