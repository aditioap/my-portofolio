from elasticsearch import Elasticsearch

es = Elasticsearch(
    "https://es.mcf.co.id:443",
    basic_auth=("elastic", "rEdodQjIJxd6121PF1taBGMR"),
    verify_certs=True   # sementara kalau pakai self-signed
)

print(es.info())
