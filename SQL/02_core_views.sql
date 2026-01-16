create or replace view vw_all_progress as
select
    b.project_code,
    b.tower_name,
    b.floor_level,
    b.activity_name,
    b.completed_units,
    p.cut_in_date as progress_date,
    TRUE as is_baseline
from baseline_progress b
join projects p
  on p.project_code = b.project_code
union all
select
    r.project_code,
    r.tower_name,
    r.floor_level,
    r.activity_name,
    r.completed_units,
    r.entry_date as progress_date,
    FALSE as is_baseline
from raw_progress_input r;


create or replace view calc_floor_activity_progress as
select 
    ap.project_code,
    ap.tower_name,
    ap.activity_name,
    ap.floor_level,
    tfu.units as units_required,
    sum(ap.completed_units) as completed_units,
    least(
        sum(ap.completed_units)::numeric / tfu.units,
        1.0
    ) as floor_completion_ratio,
    max(ap.progress_date) as actual_completion_date
from vw_all_progress ap
join tower_floor_units tfu
  on ap.project_code = tfu.project_code
 and ap.tower_name   = tfu.tower_name
 and ap.floor_level  = tfu.floor_level
group by
    ap.project_code,
    ap.tower_name,
    ap.activity_name,
    ap.floor_level,
    tfu.units;


create or replace view vw_overall_floor_completion as
select *,
    case 
        when floor_completion_ratio = 1 then TRUE
        else FALSE
    end as floor_completed_flag
from calc_floor_activity_progress;


create or replace view vw_structure_actual_floor_completion as
select * from vw_overall_floor_completion where activity_name='structure';