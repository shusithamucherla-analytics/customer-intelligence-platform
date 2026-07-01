Description: Automated ETL pipeline to extract raw retail data, validate data quality, clean and transform records, and load into SQL Server Star Schema data warehouse


import pandas as pd
import pyodbc
from datetime import datetime
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

DB_CONFIG = {
    'server': 'localhost\\SQLEXPRESS',
    'database': 'ECommerceProject',
    'driver': 'ODBC Driver 17 for SQL Server'
}

CSV_PATH = r'C:\data.csv'


def extract_data(filepath):
    logger.info("Extracting data from source...")
    df = pd.read_csv(filepath, encoding='unicode_escape', dtype=str)
    logger.info(f"Extracted {len(df)} rows successfully")
    return df


def validate_data(df):
    logger.info("Validating data quality...")
    initial = len(df)
    report = {}

    df = df.drop_duplicates()
    report['duplicates_removed'] = initial - len(df)

    df = df[df['CustomerID'].notna()]
    report['missing_customer_ids'] = initial - len(df)

    df = df[pd.to_datetime(df['InvoiceDate'], errors='coerce').notna()]

    df['Quantity'] = pd.to_numeric(df['Quantity'], errors='coerce')
    df = df[df['Quantity'].notna()]

    df['UnitPrice'] = pd.to_numeric(df['UnitPrice'], errors='coerce')
    df = df[df['UnitPrice'].notna()]
    df = df[df['UnitPrice'] > 0]

    report['final_count'] = len(df)
    report['total_removed'] = initial - len(df)
    logger.info(f"Validation complete. {len(df)} clean rows remaining")
    return df, report


def transform_data(df):
    logger.info("Transforming data...")

    df['Description'] = df['Description'].str.strip().str.title()
    df['Country'] = df['Country'].str.strip()
    df['CustomerID'] = df['CustomerID'].str.strip()
    df['StockCode'] = df['StockCode'].str.strip()
    df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])
    df['TotalRevenue'] = df['Quantity'] * df['UnitPrice']
    df['IsReturn'] = df['Quantity'] < 0

    europe = ['France', 'Germany', 'Spain', 'Italy', 'Belgium',
              'Netherlands', 'Switzerland', 'Portugal', 'Austria',
              'Denmark', 'Sweden', 'Norway', 'Finland',
              'United Kingdom', 'EIRE']
    apac = ['Australia', 'Japan', 'Singapore', 'Hong Kong']
    north_america = ['USA', 'Canada']

    df['Region'] = df['Country'].apply(
        lambda x: 'Western Europe' if x in europe
        else 'Asia Pacific' if x in apac
        else 'North America' if x in north_america
        else 'Other'
    )

    df['MarketType'] = df['Country'].apply(
        lambda x: 'Domestic' if x == 'United Kingdom'
        else 'International'
    )

    logger.info("Transformation complete")
    return df


def generate_report(df, report):
    print("\n" + "=" * 55)
    print("ETL PIPELINE EXECUTION REPORT")
    print("=" * 55)
    print(f"Run Time     : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Source       : {CSV_PATH}")
    print(f"Database     : {DB_CONFIG['database']}")
    print("-" * 55)
    print("DATA QUALITY SUMMARY")
    print(f"Initial Records   : {report.get('final_count', 0) + report.get('total_removed', 0)}")
    print(f"Duplicates Removed: {report.get('duplicates_removed', 0)}")
    print(f"Clean Records     : {report.get('final_count', 0)}")
    print(f"Total Removed     : {report.get('total_removed', 0)}")
    print("-" * 55)
    print("BUSINESS METRICS")
    print(f"Total Revenue     : £{df['TotalRevenue'].sum():,.2f}")
    print(f"Unique Customers  : {df['CustomerID'].nunique()}")
    print(f"Unique Products   : {df['StockCode'].nunique()}")
    print(f"Total Orders      : {df['InvoiceNo'].nunique()}")
    print(f"Return Transactions: {df['IsReturn'].sum()}")
    print(f"Date Range        : {df['InvoiceDate'].min().date()} to {df['InvoiceDate'].max().date()}")
    print("=" * 55)


if __name__ == "__main__":
    logger.info("ETL Pipeline Starting...")
    raw = extract_data(CSV_PATH)
    clean, report = validate_data(raw)
    transformed = transform_data(clean)
    generate_report(transformed, report)
    logger.info("ETL Pipeline Complete!!")
