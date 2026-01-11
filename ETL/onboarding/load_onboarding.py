import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from db_config import DB_config
from normalize import (
    normalize_boolean,
    normalize_dates,
    normalize_fk_nulls
)


EXCEL_PATH = r"C:\Users\darsh\OneDrive\Desktop\ALTUS 2.0\ALTUS_2.0_onboarding.xlsx"

def get_connection():
    return psycopg2.connect(**DB_config)

def bulk_insert(conn, df, table_name, columns):
    if df.empty:
        print(f"⚠️ Skipping {table_name}: no data")
        return
    values = list(df[columns].itertuples(index=False, name=None))
    sql = f"""
        INSERT INTO {table_name} ({', '.join(columns)})
        VALUES %s
    """
    with conn.cursor() as cur:
        execute_values(cur, sql, values)
    conn.commit()
    print(f"✅ Loaded {len(values)} rows into {table_name}")

def cleanup_project_onboarding(conn, project_codes):
    with conn.cursor() as cur:
        # child tables first
        cur.execute(
            "DELETE FROM baseline_progress WHERE project_code = ANY(%s);",
            (project_codes,)
        )
        cur.execute(
            "DELETE FROM mcp_dates WHERE project_code = ANY(%s);",
            (project_codes,)
        )
        cur.execute(
            "DELETE FROM contractor_activity_map WHERE project_code = ANY(%s);",
            (project_codes,)
        )
        cur.execute(
            "DELETE FROM tower_floor_units WHERE project_code = ANY(%s);",
            (project_codes,)
        )
        cur.execute(
            "DELETE FROM towers WHERE project_code = ANY(%s);",
            (project_codes,)
        )
        # parent table last
        cur.execute(
            "DELETE FROM projects WHERE project_code = ANY(%s);",
            (project_codes,)
        )
    conn.commit()
    print(f"🧹 Cleaned onboarding data for projects: {project_codes}")


def load_projects(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="project_master")
    cols = [
        "project_code",
        "project_name",
        "location",
        "project_type",
        "project_start_date",
        "cut_in_date",
        "planned_completion_date"
    ]
    bulk_insert(conn, df, "projects", cols)

def load_towers(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="towers")
    cols = [
        "project_code",
        "tower_name",
        "total_floors",
        "total_units"
    ]
    bulk_insert(conn, df, "towers", cols)

def load_tower_floor_units(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="tower_floor_units")
    cols = [
        "project_code",
        "tower_name",
        "floor_level",
        "units"
    ]
    bulk_insert(conn, df, "tower_floor_units", cols)

def load_activities(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="activities_master")
    df = normalize_boolean(df, "active_flag")
    df = normalize_fk_nulls(df, "dependency_activity")
    cols = [
        "activity_name",
        "category",
        "dependency_activity",
        "active_flag"
    ]
    values = list(df[cols].itertuples(index=False, name=None))
    sql = """
        INSERT INTO activities_master
        (activity_name, category, dependency_activity, active_flag)
        VALUES %s
        ON CONFLICT (activity_name) DO NOTHING
    """
    with conn.cursor() as cur:
        execute_values(cur, sql, values)
    conn.commit()
    print("✅ Loaded activities_master (insert-if-missing)")

def load_contractors(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="contractors")
    df = normalize_boolean(df, "active_flag")
    cols = [
        "contractor_name",
        "active_flag"
    ]
    values = list(df[cols].itertuples(index=False, name=None))
    sql = """
        INSERT INTO contractors
        (contractor_name, active_flag)
        VALUES %s
        ON CONFLICT (contractor_name) DO NOTHING
    """
    with conn.cursor() as cur:
        execute_values(cur, sql, values)
    conn.commit()
    print("✅ Loaded contractors (insert-if-missing)")


def load_contractor_activity_map(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="contractor_activity_map")
    df = normalize_boolean(df, "active_flag")
    df = normalize_dates(df, ["effective_from_date", "effective_to_date"])                                                     
    cols = [
        "project_code",
        "tower_name",
        "activity_name",
        "contractor_name",
        "effective_from_date",
        "effective_to_date",
        "active_flag"
    ]
    bulk_insert(conn, df, "contractor_activity_map", cols)


def load_baseline(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="baseline_progress")
    if df.empty:
        print("⚠️ No baseline data")
        return
    cols = [
        "project_code",
        "tower_name",
        "floor_level",
        "activity_name",
        "completed_units"
    ]
    bulk_insert(conn, df, "baseline_progress", cols)

def load_mcp(conn):
    df = pd.read_excel(EXCEL_PATH, sheet_name="mcp_dates")
    if df.empty:
        print("⚠️ No baseline data")
        return
    cols = [
        "project_code",
        "tower_name",
        "floor_level",
        "activity_name",
        "planned_date"
    ]
    bulk_insert(conn, df, "mcp_dates", cols) 

def main():
    conn = get_connection()
    print("Connected to DB:", conn.get_dsn_parameters())
    project_df = pd.read_excel(EXCEL_PATH, sheet_name="project_master")
    project_codes = project_df["project_code"].dropna().unique().tolist()
    cleanup_project_onboarding(conn, project_codes)
    load_projects(conn)
    load_towers(conn)
    load_tower_floor_units(conn)
    load_activities(conn)
    load_contractors(conn)
    load_contractor_activity_map(conn)
    load_mcp(conn)
    load_baseline(conn)

    conn.close()
    print("🎉 Onboarding completed")
     

if __name__ == "__main__":
    main()

