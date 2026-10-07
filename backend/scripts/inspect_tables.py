import sys
from pathlib import Path
from sqlalchemy import create_engine, text

backend_dir = Path(__file__).resolve().parents[1]
sys.path.append(str(backend_dir))

from app.core.config import settings

def main():
    engine = create_engine(settings.DATABASE_URL)
    with engine.connect() as conn:
        query = text("""
            SELECT 
                tablename, 
                rowsecurity 
            FROM pg_tables 
            WHERE schemaname = 'public' 
            ORDER BY tablename;
        """)
        tables = conn.execute(query).fetchall()
        print(f"{'Table Name':<25} | {'Row Count':<10} | {'RLS Enabled'}")
        print("-" * 55)
        for t, rls in tables:
            cnt = conn.execute(text(f'SELECT count(*) FROM "{t}";')).scalar()
            rls_str = "YES" if rls else "NO"
            print(f"{t:<25} | {cnt:<10} | {rls_str}")

if __name__ == "__main__":
    main()
