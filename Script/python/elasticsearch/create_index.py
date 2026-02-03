from es_client import get_es_client
from config import INDEX_NAME

es = get_es_client()

mapping = {
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 1
    },
    "mappings": {
        "properties": {
            "customer_id": {"type": "keyword"},
            "name": {"type": "text"},
            "email": {"type": "keyword"},
            "phone": {"type": "keyword"},
            "status": {"type": "keyword"},
            "created_at": {"type": "date"}
        }
    }
}

if not es.indices.exists(index=INDEX_NAME):
    es.indices.create(index=INDEX_NAME, body=mapping)
    print(f"Index '{INDEX_NAME}' created")
else:
    print(f"Index '{INDEX_NAME}' already exists")
