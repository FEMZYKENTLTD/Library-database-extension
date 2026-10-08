"""Create and verify the Unit 4 SQLite library database using only Python's standard library."""
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parents[1]
SQL_FILE = ROOT / "sql" / "library_management.sql"
DB_FILE = ROOT / "database" / "library_management.db"
DB_FILE.parent.mkdir(exist_ok=True)

with sqlite3.connect(DB_FILE) as connection:
    connection.execute("PRAGMA foreign_keys = ON;")
    connection.executescript(SQL_FILE.read_text(encoding="utf-8"))

    print(f"Database built successfully: {DB_FILE.relative_to(ROOT)}\n")
    for table in ("Books", "Members", "Loans"):
        rows = connection.execute(f"SELECT * FROM {table} ORDER BY 1").fetchall()
        print(f"{table} ({len(rows)} record(s))")
        for row in rows:
            print("  ", row)
        print()

    book_quantity = connection.execute(
        "SELECT Quantity FROM Books WHERE ISBN = '9780131103627'"
    ).fetchone()[0]
    assert book_quantity == 5, "Expected UPDATE to set quantity to 5."
    assert connection.execute("SELECT COUNT(*) FROM Members WHERE MemberID = 'M003'").fetchone()[0] == 0, \
        "Expected DELETE to remove M003."
    print("Verification passed: UPDATE and DELETE results match the documented screenshots.")
