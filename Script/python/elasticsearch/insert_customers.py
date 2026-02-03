from datetime import datetime, timedelta
from es_client import get_es_client
from config import INDEX_NAME

es = get_es_client()

customers = []
base_time = datetime.now()

for i in range(1, 11):
    customers.append({
        "customer_id": f"CUST-{i:03}",
        "name": f"Customer {i}",
        "email": f"customer{i}@example.com",
        "phone": f"+62-812-000{i:03}",
        "status": "ACTIVE" if i % 2 == 0 else "INACTIVE",
        "created_at": (base_time - timedelta(days=i)).isoformat()
    })

for customer in customers:
    es.index(index=INDEX_NAME, document=customer)

print("10 customers inserted successfully")
