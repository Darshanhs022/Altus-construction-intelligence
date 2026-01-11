import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from db_config import DB_config
from normalize import normalize_dates

EXCEL_PATH = r"C:\Users\darsh\OneDrive\Desktop\ALTUS 2.0\monthly_plan.xlsx"


def get_connection():
    return psycopg2.connect(**DB_config)


def load_monthly_plan():
    df = pd.read_excel(EXCEL_PATH, sheet_name="monthly_planned")

    if df.empty:
        print("⚠️ No monthly plan data")
        return

    # 🔹 normalize only what is required
    df = normalize_dates(df, ["plan_month"])

    cols = [
        "project_code",
        "tower_name",
        "activity_name",
        "plan_month",
        "planned_units"
    ]

    values = list(df[cols].itertuples(index=False, name=None))

    sql = """
        INSERT INTO monthly_planned_units
        (project_code, tower_name, activity_name, plan_month, planned_units)
        VALUES %s
        ON CONFLICT (project_code, tower_name, activity_name, plan_month)
        DO UPDATE
        SET planned_units = EXCLUDED.planned_units,
            uploaded_on = CURRENT_TIMESTAMP;
    """

    conn = get_connection()
    with conn.cursor() as cur:
        execute_values(cur, sql, values)

    conn.commit()
    conn.close()

    print(f"✅ Loaded {len(values)} monthly plan rows")


if __name__ == "__main__":
    load_monthly_plan()
