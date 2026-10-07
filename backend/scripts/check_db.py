import re
import sys
from pathlib import Path
from sqlalchemy import create_engine, text

# Add backend directory to sys.path
backend_dir = Path(__file__).resolve().parents[1]
sys.path.append(str(backend_dir))

from app.core.config import settings

def sanitize(msg: str) -> str:
    # Strip any postgresql connection strings, credentials, or hosts
    sanitized = re.sub(r"postgresql(?:\+[a-zA-Z0-9]+)?://[^@\s]+@[^\s/:]+(?::\d+)?/[^\s\?]+", "[REDACTED_URL]", msg)
    sanitized = re.sub(r"://[^:]+:[^@]+@", "://[REDACTED_CREDENTIALS]@", sanitized)
    sanitized = re.sub(r"password=([^\s]+)", "password=[REDACTED]", sanitized, flags=re.IGNORECASE)
    return sanitized

def main():
    try:
        engine = create_engine(settings.DATABASE_URL, connect_args={"connect_timeout": 5})
        with engine.connect() as conn:
            pg_ver = conn.execute(text("SELECT version();")).scalar()
            # Try checking PostGIS
            postgis_ver = None
            try:
                postgis_ver = conn.execute(text("SELECT PostGIS_Version();")).scalar()
            except Exception:
                postgis_ver = "not installed or not enabled in search_path"

            print("connected: yes")
            print(f"PostgreSQL version: {pg_ver}")
            print(f"PostGIS version: {postgis_ver}")
            return 0
    except Exception as exc:
        print("connected: no")
        err_type = type(exc).__name__
        err_msg = sanitize(str(exc)).split("\n")[0]
        print(f"Error: {err_type} - {err_msg}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
