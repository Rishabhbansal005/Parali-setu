"""
Seed script for ParaliSetu demo data per SPEC.md Section 14.
All data created by this script is SIMULATED for the demo.
"""
from __future__ import annotations
import uuid
import datetime
from sqlalchemy.orm import Session
from geoalchemy2.shape import from_shape
from shapely.geometry import Point

from app.core.database import SessionLocal, engine, Base
from app.models.user import User
from app.models.farm import Farm
from app.models.buyer import Buyer
from app.models.machine import Machine
from app.models.truck import Truck

# Tarn Taran / Amritsar region centroid: ~31.45 N, 74.92 E
DISTRICT_LAT = 31.4519
DISTRICT_LON = 74.9272

def seed_demo_data():
    db: Session = SessionLocal()
    print("Seeding SIMULATED demo data per SPEC.md §14...")

    try:
        # Check if already seeded
        existing = db.query(User).filter(User.phone_e164.like("+9198100%")).count()
        if existing >= 20:
            print(f"Database already seeded with {existing} simulated records. Skipping.")
            return

        # 1. 20 Farmers (SPEC.md Section 14.1)
        farmer_data = [
            ("Gurpreet Singh", "Bhikhiwind", "Tarn Taran", 4.0, "PR-126", "2026-10-18"),
            ("Amarjit Kaur", "Patti", "Tarn Taran", 2.5, "PR-126", "2026-10-19"),
            ("Sukhwinder Singh", "Harike", "Ferozepur", 6.0, "Pusa-44", "2026-10-20"),
            ("Harpreet Kaur", "Zira", "Ferozepur", 3.5, "Basmati", "2026-10-22"),
            ("Kulwant Kaur", "Makhu", "Ferozepur", 2.0, "PR-126", "2026-10-17"),
            ("Balwinder Singh", "Kartarpur", "Jalandhar", 5.0, "PR-126", "2026-10-21"),
            ("Harjinder Singh", "Nakodar", "Jalandhar", 3.0, "Pusa-44", "2026-10-23"),
            ("Manpreet Singh", "Khanna", "Ludhiana", 4.5, "PR-126", "2026-10-18"),
            ("Rajwinder Kaur", "Raikot", "Ludhiana", 2.5, "PR-126", "2026-10-20"),
            ("Satnam Singh", "Moga", "Moga", 3.0, "Pusa-44", "2026-10-19"),
            ("Daljit Singh", "Nihal Singh Wala", "Moga", 5.5, "PR-126", "2026-10-21"),
            ("Kashmir Singh", "Fazilka", "Fazilka", 4.0, "Basmati", "2026-10-25"),
            ("Avtar Singh", "Abohar", "Fazilka", 6.5, "PR-126", "2026-10-17"),
            ("Lakhvir Kaur", "Malout", "Sri Muktsar Sahib", 3.0, "PR-126", "2026-10-18"),
            ("Jaswant Singh", "Lambi", "Sri Muktsar Sahib", 2.0, "Pusa-44", "2026-10-20"),
            ("Ranjit Singh", "Hansi", "Hisar", 4.0, "Pusa-44", "2026-10-23"),
            ("Ramesh Kumar", "Tohana", "Fatehabad", 3.5, "Pusa-44", "2026-10-19"),
            ("Sunder Lal", "Narwana", "Jind", 2.5, "Pusa-44", "2026-10-21"),
            ("Dharamvir Singh", "Kaithal", "Kaithal", 4.5, "PR-126", "2026-10-18"),
            ("Ram Singh", "Shamli", "Shamli", 3.0, "PR-126", "2026-10-22"),
        ]

        for i, (name, village, dist, acres, variety, harv_date) in enumerate(farmer_data, start=1):
            phone = f"+9198100{i:05d}"
            user = User(
                phone_e164=phone,
                name=name,
                preferred_language="pa" if dist in ["Tarn Taran", "Ferozepur", "Ludhiana", "Moga", "Jalandhar"] else "hi",
                roles=["farmer"],
                village=village,
                district=dist,
                state="Punjab" if dist not in ["Hisar", "Fatehabad", "Jind", "Kaithal", "Shamli"] else ("Haryana" if dist != "Shamli" else "Uttar Pradesh")
            )
            db.add(user)
            db.flush()

            # Add Farm for farmer
            pt = Point(DISTRICT_LON + (i * 0.01), DISTRICT_LAT + (i * 0.01))
            farm = Farm(
                farmer_id=user.id,
                name=f"{village} Field",
                area_acres=acres,
                paddy_variety=variety,
                harvest_method="combine",
                location=from_shape(pt, srid=4326),
                khasra_number=f"KH-{100 + i}",
            )
            db.add(farm)

        # 2. 5 Buyers (SPEC.md Section 14.2)
        buyer_data = [
            ("Punjab Biogas Cooperative", "biogas", "Ludhiana", 1200, 50, datetime.date(2026, 10, 15), datetime.date(2026, 11, 15)),
            ("Malwa Biomass Power Plant", "pellet", "Muktsar", 900, 30, datetime.date(2026, 10, 10), datetime.date(2026, 11, 20)),
            ("GreenFuel Pellets Pvt Ltd", "pellet", "Jalandhar", 1100, 40, datetime.date(2026, 10, 18), datetime.date(2026, 11, 20)),
            ("Agri Energy Ltd", "biogas", "Hisar", 1150, 60, datetime.date(2026, 10, 20), datetime.date(2026, 11, 25)),
            ("Haryana Agri Power", "pellet", "Jind", 1050, 25, datetime.date(2026, 10, 17), datetime.date(2026, 11, 15)),
        ]
        for i, (bname, btype, dist, price, max_d, wstart, wend) in enumerate(buyer_data, start=1):
            user = User(
                phone_e164=f"+9198200{i:05d}",
                name=f"{bname} Rep",
                roles=["buyer"],
                district=dist,
            )
            db.add(user)
            db.flush()

            bpt = Point(DISTRICT_LON + (i * 0.03), DISTRICT_LAT + (i * 0.03))
            buyer = Buyer(
                user_id=user.id,
                business_name=bname,
                business_type=btype,
                location=from_shape(bpt, srid=4326),
                max_distance_km=max_d,
                price_per_tonne_inr=price,
                moisture_limit_pct=20.0,
                min_batch_tonnes=10.0,
                demand_window_start=wstart,
                demand_window_end=wend,
            )
            db.add(buyer)

        # 3. 6 Machines (SPEC.md Section 14.3)
        machine_data = [
            ("SMAM_straw_mgmt", "Avtar Machinery", "Tarn Taran", 8, 800),
            ("baler", "Kisan Services", "Ferozepur", 10, 750),
            ("SMAM_straw_mgmt", "Singh Agri Works", "Ludhiana", 8, 820),
            ("shredder", "Punjab Agri", "Jalandhar", 12, 700),
            ("baler", "Haryana Agri", "Hisar", 10, 780),
            ("SMAM_straw_mgmt", "Jind Machinery", "Jind", 8, 800),
        ]
        for i, (mtype, brand, dist, cap, rate) in enumerate(machine_data, start=1):
            user = User(
                phone_e164=f"+9198300{i:05d}",
                name=f"{brand} Owner",
                roles=["machine_owner"],
                district=dist,
            )
            db.add(user)
            db.flush()

            mpt = Point(DISTRICT_LON + (i * 0.02), DISTRICT_LAT + (i * 0.02))
            machine = Machine(
                owner_id=user.id,
                machine_type=mtype,
                brand=brand,
                capacity_acres_per_day=cap,
                location=from_shape(mpt, srid=4326),
                price_per_acre_inr=rate,
                availability_start=datetime.date(2026, 10, 10),
                availability_end=datetime.date(2026, 11, 25),
            )
            db.add(machine)

        # 4. 5 Trucks (SPEC.md Section 14.4)
        truck_data = [
            ("Gurpreet Transport", "Tarn Taran", 10, 2.5),
            ("Singh Logistics", "Ferozepur", 12, 2.3),
            ("Ludhiana Carriers", "Ludhiana", 15, 2.2),
            ("Haryana Transport Co", "Hisar", 10, 2.4),
            ("Jind Freight", "Jind", 12, 2.3),
        ]
        for i, (brand, dist, cap, rate) in enumerate(truck_data, start=1):
            user = User(
                phone_e164=f"+9198400{i:05d}",
                name=f"{brand} Driver",
                roles=["truck_owner"],
                district=dist,
            )
            db.add(user)
            db.flush()

            tpt = Point(DISTRICT_LON + (i * 0.025), DISTRICT_LAT + (i * 0.025))
            truck = Truck(
                owner_id=user.id,
                capacity_tonnes=cap,
                location=from_shape(tpt, srid=4326),
                price_per_tonne_km_inr=rate,
                availability_start=datetime.date(2026, 10, 10),
                availability_end=datetime.date(2026, 11, 25),
            )
            db.add(truck)

        db.commit()
        print("SIMULATED demo data successfully seeded! (20 farmers, 5 buyers, 6 machines, 5 trucks)")

    except Exception as e:
        db.rollback()
        print(f"Error seeding demo data: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_demo_data()
