import pandas as pd


def normalize_boolean(df, column, default=False):
    if column in df.columns:
        df[column] = (
            df[column]
            .fillna(default)
            .astype(int)
            .astype(bool)
        )
    return df


def normalize_dates(df, columns):
    for col in columns:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")
            df[col] = df[col].astype(object)
            df[col] = df[col].where(df[col].notna(), None)
    return df


def normalize_fk_nulls(df, column):
    if column in df.columns:
        df[column] = df[column].where(pd.notna(df[column]), None)
    return df
