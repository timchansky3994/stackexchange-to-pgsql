import argparse
import sys
from getpass import getpass
import xml.etree.ElementTree as ET
import psycopg2
from psycopg2.extras import execute_batch


def import_xml_to_postgres(xml_file, table_name, schema_name, db_params, batch_size=1000):
    # Connect to PostgreSQL
    conn = psycopg2.connect(**db_params)
    cur = conn.cursor()

    # Get table columns from database schema
    cur.execute(f"""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_schema = %s AND table_name = %s
    """, (schema_name.lower(), table_name.lower()))
    columns = {row[0]: row[1] for row in cur.fetchall()}

    if not columns:
        raise ValueError(f"No columns found for table {schema_name}.{table_name}")

    # Parse XML and prepare data
    data = []
    for event, elem in ET.iterparse(xml_file, events=('end',)):
        if elem.tag == 'row':
            row_data = dict((k.lower(), v) for k, v in elem.attrib.items())
            data.append(row_data)
            elem.clear()

            # Batch insert
            if len(data) >= batch_size:
                insert_batch(cur, table_name, columns, data, schema_name)
                conn.commit()
                data = []

    # Insert remaining records
    if data:
        insert_batch(cur, table_name, columns, data, schema_name)
        conn.commit()

    cur.close()
    conn.close()


def insert_batch(cur, table_name, columns, data, schema_name):
    columns_str = ', '.join(columns.keys())
    placeholders = ', '.join(['%s'] * len(columns))
    cur.execute(f"ALTER TABLE {schema_name.lower()}.{table_name.lower()} DISABLE TRIGGER ALL")
    query = f"""
        INSERT INTO {schema_name.lower()}.{table_name.lower()} ({columns_str})
        VALUES ({placeholders})
        ON CONFLICT (id) DO NOTHING
    """
    batch = [tuple(row.get(col) for col in columns) for row in data]
    execute_batch(cur, query, batch)
    cur.execute(f"ALTER TABLE {schema_name.lower()}.{table_name.lower()} ENABLE TRIGGER ALL")


def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description='Import StackExchange XML data into PostgreSQL',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    # Required arguments
    parser.add_argument('--xml', required=True,
                        help='Path to XML file to import')
    parser.add_argument('--table', required=True,
                        help='Target table name (e.g., posts)')

    # Database connection arguments
    parser.add_argument('--schema', default='StackExchange',
                        help='Database schema name')
    parser.add_argument('--dbname', default='StackExchangeDB',
                        help='Database name')
    parser.add_argument('--user', default='postgres',
                        help='Database user')
    parser.add_argument('--host', default='localhost',
                        help='Database host')
    parser.add_argument('--port', type=int, default=5432,
                        help='Database port')

    # Optional arguments
    parser.add_argument('--batch-size', type=int, default=1000,
                        help='Number of records per batch insert')
    parser.add_argument('--log-level', default='info',
                        choices=['debug', 'info', 'warning'],
                        help='Logging level')

    args = parser.parse_args()
    password = getpass('Database password: ')

    # Run import
    try:
        import_xml_to_postgres(
            xml_file=args.xml,
            table_name=args.table,
            schema_name=args.schema,
            db_params={
                'dbname': args.dbname,
                'user': args.user,
                'password': password,
                'host': args.host,
                'port': args.port,
                'client_encoding': 'utf-8'
            },
            batch_size=args.batch_size
        )
    except Exception as e:
        print(f"Import failed: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
