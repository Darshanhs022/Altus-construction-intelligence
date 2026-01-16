create or replace view vw_structure_slab_cycle_analysis as
with ordered_floors as (
    select
        project_code,
        tower_name,
        floor_level,
        actual_completion_date,
        lag(actual_completion_date) over (
            partition by project_code, tower_name
            order by floor_level
        ) as prev_floor_completion_date
    from vw_structure_actual_floor_completion
    where floor_completed_flag = TRUE
)
select
    project_code,
    tower_name,
    floor_level,
    actual_completion_date,
    prev_floor_completion_date,
    (actual_completion_date - prev_floor_completion_date) 
        as slab_cycle_days,
    case
        when prev_floor_completion_date is null then 'FIRST SLAB'
        when (actual_completion_date - prev_floor_completion_date) <= 10
            then '≤ 10 DAYS'
        when (actual_completion_date - prev_floor_completion_date) <= 15
            then '11–15 DAYS'
        when (actual_completion_date - prev_floor_completion_date) <= 20
            then '16–20 DAYS'
        else '> 20 DAYS'
    end as slab_cycle_bucket
from ordered_floors;


create or replace view vw_structure_mcp_vs_actual as
select 
    f.project_code,
    f.tower_name,
    f.floor_level,
    m.planned_date AS mcp_date,
    f.actual_completion_date,
	case
	    when f.actual_completion_date is null then null
		else (f.actual_completion_date - m.planned_date) 
	end as delay_days,
	case
	    when f.floor_completion_ratio < 1 then 'IN PROGRESS'
        when f.actual_completion_date <= m.planned_date then 'ON / AHEAD'
        else 'DELAYED'
	end as schedule_status	
from vw_structure_actual_floor_completion f
left join mcp_dates m
   on f.project_code=m.project_code
  and f.tower_name=m.tower_name
  and f.floor_level=m.floor_level;


create or replace view vw_structure_mcp_vs_actual as
select 
    f.project_code,
    f.tower_name,
    f.floor_level,
    m.planned_date as mcp_date,
    f.actual_completion_date,
	case
	    when f.actual_completion_date is null then null
		else (f.actual_completion_date - m.planned_date) 
	end as delay_days,
	case
	    when f.floor_completion_ratio < 1 then 'in progress'
        when f.actual_completion_date <= m.planned_date then 'on / ahead'
        else 'delayed'
	end as schedule_status	
from vw_structure_actual_floor_completion f
left join mcp_dates m
   on f.project_code=m.project_code
  and f.tower_name=m.tower_name
  and f.floor_level=m.floor_level;


create or replace view vw_tower_activity_stagnation as
select
    ap.project_code,
    ap.tower_name,
    ap.activity_name,
    max(ap.progress_date) as last_progress_date,
    (select as_of_date from vw_analysis_date)
      - max(ap.progress_date) as days_since_last_progress,
    case
        when (select as_of_date from vw_analysis_date)- max(ap.progress_date) <= 12 then 'active'
        when (select as_of_date from vw_analysis_date)- max(ap.progress_date) <= 18 then 'slow'
        else 'stagnant'
    end as stagnation_status
from vw_all_progress ap
where ap.is_baseline = false
group by
    ap.project_code,
    ap.tower_name,
    ap.activity_name;


create or replace view vw_tower_activity_bottleneck as
with tower_avg as (
    select
        project_code,
        tower_name,
        avg(completion_pct) as avg_completion_pct
    from vw_tower_finishing_activity_progress
    group by project_code, tower_name
)
select
    f.project_code,
    f.tower_name,
    f.activity_name,
    f.completed_units,
    f.total_units,
    f.pending_units,
    f.completion_pct,
    a.avg_completion_pct,
    round(
        f.completion_pct - a.avg_completion_pct,
        1
    ) as deviation_from_tower_avg,
    case
        when f.completion_pct < a.avg_completion_pct - 25 then 'critical lag'
        when f.completion_pct < a.avg_completion_pct - 10 then 'lagging'
        else 'on track'
    end as progress_flag
from vw_tower_finishing_activity_progress f
join tower_avg a
  on a.project_code = f.project_code
 and a.tower_name   = f.tower_name;


create or replace view vw_project_activity_critical_lag as
with finishing_activity_totals as (
    select
        project_code,
        activity_name,
        sum(completed_units) as completed_units,
        sum(total_units)     as total_units,
        round(
            sum(completed_units)::numeric
            / nullif(sum(total_units), 0) * 100,
            1
        ) as completion_pct
    from vw_tower_finishing_activity_progress
    group by project_code, activity_name
),
structure_activity_totals as (
    select
        project_code,
        'structure' as activity_name,
        sum(structure_completed_units) as completed_units,
        sum(structure_total_units)     as total_units,
        round(
            sum(structure_completed_units)::numeric
            / nullif(sum(structure_total_units), 0) * 100,
            1
        ) as completion_pct
    from vw_tower_structure_progress
    group by project_code
),
activity_totals as (
    select * from finishing_activity_totals
    union all
    select * from structure_activity_totals
),
project_avg as (
    select
        project_code,
        avg(completion_pct) as project_avg_completion_pct
    from activity_totals
    group by project_code
)
select
    a.project_code,
    a.activity_name,
    a.completed_units,
    a.total_units,
    a.completion_pct,
    p.project_avg_completion_pct,
    round(
        a.completion_pct - p.project_avg_completion_pct,
        1
    ) as deviation_from_project_avg,
    case
        when a.completion_pct < p.project_avg_completion_pct - 25 then 'critical lag'
        when a.completion_pct < p.project_avg_completion_pct - 10 then 'lagging'
        else 'on track'
    end as progress_flag
from activity_totals a
join project_avg p
  on p.project_code = a.project_code;

