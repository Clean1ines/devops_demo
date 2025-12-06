from fastapi import FastAPI, Response
from datetime import datetime
from prometheus_client import Counter, Gauge, generate_latest

app = FastAPI(title="Neolant Monitoring API")

# Метрики Prometheus
REQUESTS_TOTAL = Counter('api_requests_total', 'Total API requests', ['endpoint'])
ACTIVE_CONNECTIONS = Gauge('api_active_connections', 'Active API connections')

@app.get("/")
def read_root():
    REQUESTS_TOTAL.labels(endpoint="/").inc()
    return {"message": "Industrial Monitoring System"}

@app.get("/health")
def health_check():
    REQUESTS_TOTAL.labels(endpoint="/health").inc()
    return {
        "status": "healthy",
        "service": "python-api",
        "timestamp": datetime.utcnow().isoformat(),
        "database": "connected"
    }

# Бизнес-метрики в JSON формате (должен быть доступен по /api/metrics)
@app.get("/api/metrics")
def get_business_metrics():
    REQUESTS_TOTAL.labels(endpoint="/api/metrics").inc()
    ACTIVE_CONNECTIONS.inc()
    try:
        return {
            "industrial_objects": 42,
            "equipment_total": 156,
            "uptime_percentage": 99.87,
            "timestamp": datetime.utcnow().isoformat()
        }
    finally:
        ACTIVE_CONNECTIONS.dec()

# Prometheus метрики в текстовом формате (должен быть доступен по /metrics)
@app.get("/metrics")
def prometheus_metrics():
    REQUESTS_TOTAL.labels(endpoint="/metrics").inc()
    return Response(generate_latest(), media_type="text/plain")
