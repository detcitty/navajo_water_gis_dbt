import os
import glob
import duckdb

# 1. Configuration
DB_FILE = "./navajo_water_wells/data/navajo_water_wells.duckdb"
SOURCE_FOLDER = "./navajo_water_wells/raw_data"  # Directory where your CSVs live

def load_multiple_csvs():
    # Ensure target directory exists
    if not os.path.exists(SOURCE_FOLDER):
        print(f"Error: Folder '{SOURCE_FOLDER}' does not exist.")
        return

    # Find all CSV files in the folder
    csv_files = glob.glob(os.path.join(SOURCE_FOLDER, "*.csv"))
    
    if not csv_files:
        print(f"No CSV files found in '{SOURCE_FOLDER}'.")
        return

    print(f"Found {len(csv_files)} CSV files. Connecting to DuckDB: {DB_FILE}...")
    conn = duckdb.connect(DB_FILE)

    try:
        for csv_path in csv_files:
            # Extract file name without extension to use as table name
            # Example: './data_folder/users.csv' -> 'users'
            file_name = os.path.basename(csv_path)
            table_name = os.path.splitext(file_name)[0]
            
            print(f"Processing: {file_name} -> Table: {table_name}")
            
            # Drop old table and create a new one from the current CSV
            conn.execute(f"DROP TABLE IF EXISTS {table_name};")
            conn.execute(f"CREATE TABLE {table_name} AS FROM '{csv_path}';")
            
            row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name};").fetchone()[0]
            print(f"  └ Loaded {row_count} rows.")

        print("\nAll files successfully processed!")

    except Exception as e:
        print(f"An error occurred: {e}")
        
    finally:
        conn.close()
        print("Database connection closed.")

if __name__ == "__main__":
    load_multiple_csvs()
