create or replace view vw_tower_structure_progress as
select
   f.project_code,
   f.tower_name,
   sum (f.units_completed) as structure_completed_units,
   t.total_units as structure_total_units,
   (t.total_units - sum(f.units_completed)) as structure_pending_units,
   sum (f.floor_completion_ratio) as structure_completed_floors,
   ROUND(
       (SUM(f.units_completed)::numeric / t.total_units) * 100,
       1
    ) AS structure_completion_pct
from vw_structure_actual_floor_completion f
join towers t
  on t.project_code = f.project_code
 and t.tower_name = f.tower_name
group by 
    f.project_code,
    f.tower_name,
    t.total_units;


create or replace view vw_overall_total_units as
select
    t.project_code,
    t.tower_name,
    cam.activity_name,
    sum(tfu.units) as total_units
from tower_floor_units tfu
join towers t
  on t.project_code = tfu.project_code
 and t.tower_name   = tfu.tower_name
join contractor_activity_map cam
  on cam.project_code = t.project_code
 and cam.tower_name   = t.tower_name
group by
    t.project_code,
    t.tower_name,
    cam.activity_name;    

create or replace view vw_finishing_total_units as
select * from vw_overall_total_units
where activity_name !='structure';


create or replace view vw_overall_completed_units as 
select 
     ap.project_code,
	 ap.tower_name,
	 ap.activity_name,
	 sum(ap.completed_units) as completed_units,
	 round(
	   sum(
          least(ap.completed_units::numeric/tfu.units,1.0)
	      ),
		  1
	  )as completed_floors  
from vw_all_progress ap
join tower_floor_units as tfu 
   on ap.project_code=tfu.project_code
  and ap.tower_name=tfu.tower_name
  and ap.floor_level=tfu.floor_level 
group by
    ap.project_code,
    ap.tower_name,
    ap.activity_name;


create or replace view vw_finishing_completed_units as
select * from vw_overall_completed_units
where activity_name != 'structure';


create or replace view vw_tower_finishing_activity_progress as
select
    s.project_code,
    s.tower_name,
    s.activity_name,
    coalesce(c.completed_units, 0) as completed_units,
    s.total_units,
    (s.total_units - coalesce(c.completed_units, 0)) as pending_units,
    coalesce(c.completed_floors, 0) as completed_floors,
    round(
        coalesce(c.completed_units, 0)::numeric / s.total_units * 100,
        1
    ) as completion_pct,
    cam.contractor_name
from vw_finishing_total_units s
left join vw_finishing_completed_units c
  on c.project_code = s.project_code
 and c.tower_name   = s.tower_name
 and c.activity_name = s.activity_name
left join contractor_activity_map cam
  on cam.project_code = s.project_code
 and cam.tower_name   = s.tower_name
 and cam.activity_name = s.activity_name;


create or replace view vw_tower_activity_progress_all as
select
    tower_name,
    'structure' as activity,
    structure_completed_units as completed_units,
    structure_total_units     as total_units,
    structure_completion_pct  as completion_pct
from vw_tower_structure_progress
union all
select
    tower_name,
    activity_name,
    completed_units,
    total_units,
    completion_pct
from vw_tower_finishing_activity_progress;


