from elasticsearch import Elasticsearch
from config import ES_URL, ES_USER, ES_PASSWORD

def get_es_client():
    return Elasticsearch(
        ES_URL,
        basic_auth=(ES_USER, ES_PASSWORD),
        verify_certs=True  # use Company Cert
    )
