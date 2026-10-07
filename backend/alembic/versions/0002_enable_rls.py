"""0002_enable_rls

Revision ID: 0002_enable_rls
Revises: 0001_initial_schema
Create Date: 2026-10-08 01:20:00.000000

"""
from alembic import op

# revision identifiers, used by Alembic.
revision = '0002_enable_rls'
down_revision = '0001_initial_schema'
branch_labels = None
depends_on = None

TABLES = [
    "users",
    "farms",
    "buyers",
    "machines",
    "trucks",
    "bookings",
    "estimates",
    "offers",
    "payments",
    "burn_checks",
    "impact_log",
    "weighbridge_records",
]

def upgrade() -> None:
    for table in TABLES:
        op.execute(f'ALTER TABLE "{table}" ENABLE ROW LEVEL SECURITY;')

def downgrade() -> None:
    for table in TABLES:
        op.execute(f'ALTER TABLE "{table}" DISABLE ROW LEVEL SECURITY;')
