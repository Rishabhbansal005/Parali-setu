"""0001_initial_schema

Revision ID: 0001_initial_schema
Revises: 
Create Date: 2026-10-07 16:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import geoalchemy2

# revision identifiers, used by Alembic.
revision = '0001_initial_schema'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Ensure postgis extension exists
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
    op.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto;")

    # 1. users
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('phone_e164', sa.String(length=20), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=True),
        sa.Column('preferred_language', sa.String(length=10), server_default='hi', nullable=False),
        sa.Column('roles', postgresql.ARRAY(sa.String()), server_default='{}', nullable=False),
        sa.Column('village', sa.String(length=100), nullable=True),
        sa.Column('district', sa.String(length=100), nullable=True),
        sa.Column('state', sa.String(length=100), server_default='Punjab', nullable=False),
        sa.Column('fcm_token', sa.Text(), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('phone_e164')
    )

    # 2. farms
    op.create_table(
        'farms',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('farmer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=True),
        sa.Column('area_acres', sa.Numeric(precision=6, scale=2), nullable=False),
        sa.Column('paddy_variety', sa.String(length=50), nullable=True),
        sa.Column('harvest_method', sa.String(length=20), nullable=True),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326, from_text='ST_GeomFromEWKT', name='geometry'), nullable=True),
        sa.Column('boundary', geoalchemy2.types.Geometry(geometry_type='POLYGON', srid=4326, from_text='ST_GeomFromEWKT', name='geometry'), nullable=True),
        sa.Column('khasra_number', sa.String(length=50), nullable=True),
        sa.ForeignKeyConstraint(['farmer_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # 3. estimates
    op.create_table(
        'estimates',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('farm_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('requested_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('harvest_date', sa.Date(), nullable=False),
        sa.Column('wheat_sow_date', sa.Date(), nullable=True),
        sa.Column('stubble_tonnes_low', sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column('stubble_tonnes_mid', sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column('stubble_tonnes_high', sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column('income_low_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('income_high_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('config_snapshot', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.ForeignKeyConstraint(['farm_id'], ['farms.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # 4. buyers
    op.create_table(
        'buyers',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('business_name', sa.String(length=200), nullable=False),
        sa.Column('business_type', sa.String(length=50), nullable=False),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326, from_text='ST_GeomFromEWKT', name='geometry'), nullable=True),
        sa.Column('max_distance_km', sa.Numeric(precision=6, scale=1), nullable=True),
        sa.Column('price_per_tonne_inr', sa.Numeric(precision=8, scale=2), nullable=True),
        sa.Column('moisture_limit_pct', sa.Numeric(precision=4, scale=1), nullable=True),
        sa.Column('min_batch_tonnes', sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column('max_batch_tonnes', sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column('demand_window_start', sa.Date(), nullable=True),
        sa.Column('demand_window_end', sa.Date(), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # 5. machines
    op.create_table(
        'machines',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('owner_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('machine_type', sa.String(length=50), nullable=False),
        sa.Column('brand', sa.String(length=100), nullable=True),
        sa.Column('capacity_acres_per_day', sa.Numeric(precision=5, scale=2), nullable=True),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326, from_text='ST_GeomFromEWKT', name='geometry'), nullable=True),
        sa.Column('price_per_acre_inr', sa.Numeric(precision=8, scale=2), nullable=True),
        sa.Column('availability_start', sa.Date(), nullable=True),
        sa.Column('availability_end', sa.Date(), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('photos', postgresql.ARRAY(sa.String()), nullable=True),
        sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # 6. trucks
    op.create_table(
        'trucks',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('owner_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('capacity_tonnes', sa.Numeric(precision=6, scale=2), nullable=True),
        sa.Column('location', geoalchemy2.types.Geometry(geometry_type='POINT', srid=4326, from_text='ST_GeomFromEWKT', name='geometry'), nullable=True),
        sa.Column('price_per_tonne_km_inr', sa.Numeric(precision=8, scale=4), nullable=True),
        sa.Column('availability_start', sa.Date(), nullable=True),
        sa.Column('availability_end', sa.Date(), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default='true', nullable=False),
        sa.Column('photos', postgresql.ARRAY(sa.String()), nullable=True),
        sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )

    # 7. offers
    op.create_table(
        'offers',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('estimate_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('machine_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('truck_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('buyer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('proposed_pickup_date', sa.Date(), nullable=True),
        sa.Column('machine_cost_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('transport_cost_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('gross_income_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('net_income_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('rank', sa.SmallInteger(), nullable=True),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['buyer_id'], ['buyers.id']),
        sa.ForeignKeyConstraint(['estimate_id'], ['estimates.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['machine_id'], ['machines.id']),
        sa.ForeignKeyConstraint(['truck_id'], ['trucks.id']),
        sa.PrimaryKeyConstraint('id')
    )

    # 8. bookings
    op.create_table(
        'bookings',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('offer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('farmer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('proxy_user_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('status', sa.String(length=30), server_default='requested', nullable=False),
        sa.Column('cancelled_reason', sa.Text(), nullable=True),
        sa.Column('cancellation_actor', sa.String(length=30), nullable=True),
        sa.Column('confirmed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('picked_up_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('weighed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('paid_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('verified_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['farmer_id'], ['users.id']),
        sa.ForeignKeyConstraint(['offer_id'], ['offers.id']),
        sa.ForeignKeyConstraint(['proxy_user_id'], ['users.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('offer_id')
    )

    # 9. payments
    op.create_table(
        'payments',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('booking_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('provider', sa.String(length=30), server_default='mock', nullable=False),
        sa.Column('provider_order_id', sa.String(length=200), nullable=True),
        sa.Column('escrow_amount_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('final_amount_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('platform_fee_inr', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('status', sa.String(length=30), server_default='held', nullable=False),
        sa.Column('held_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('released_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('refunded_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['booking_id'], ['bookings.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('booking_id')
    )

    # 10. weighbridge_records
    op.create_table(
        'weighbridge_records',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('booking_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('submitted_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('weight_kg', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('ticket_number', sa.String(length=100), nullable=True),
        sa.Column('ticket_image_url', sa.Text(), nullable=True),
        sa.Column('farmer_confirmed', sa.Boolean(), nullable=True),
        sa.Column('buyer_confirmed', sa.Boolean(), nullable=True),
        sa.Column('disputed', sa.Boolean(), server_default='false', nullable=False),
        sa.Column('dispute_notes', sa.Text(), nullable=True),
        sa.Column('measured_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['booking_id'], ['bookings.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['submitted_by'], ['users.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('booking_id')
    )

    # 11. burn_checks
    op.create_table(
        'burn_checks',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('booking_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('farm_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('checked_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('satellite_source', sa.String(length=30), nullable=True),
        sa.Column('image_date', sa.Date(), nullable=True),
        sa.Column('cloud_cover_pct', sa.Numeric(precision=5, scale=2), nullable=True),
        sa.Column('burn_detected', sa.Boolean(), nullable=True),
        sa.Column('burn_severity', sa.String(length=20), nullable=True),
        sa.Column('burn_fraction', sa.Numeric(precision=5, scale=4), nullable=True),
        sa.Column('result_state', sa.String(length=30), server_default='unclear', nullable=False),
        sa.Column('vlm_raw_response', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['booking_id'], ['bookings.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['farm_id'], ['farms.id']),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('booking_id')
    )

    # 12. impact_log
    op.create_table(
        'impact_log',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('booking_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('stubble_kg', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('co2_eq_kg_avoided', sa.Numeric(precision=12, scale=2), nullable=True),
        sa.Column('pm25_kg_avoided', sa.Numeric(precision=10, scale=4), nullable=True),
        sa.Column('equivalent_trees', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('calculation_version', sa.String(length=20), nullable=True),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(['booking_id'], ['bookings.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('booking_id')
    )

def downgrade() -> None:
    op.drop_table('impact_log')
    op.drop_table('burn_checks')
    op.drop_table('weighbridge_records')
    op.drop_table('payments')
    op.drop_table('bookings')
    op.drop_table('offers')
    op.drop_table('trucks')
    op.drop_table('machines')
    op.drop_table('buyers')
    op.drop_table('estimates')
    op.drop_table('farms')
    op.drop_table('users')
