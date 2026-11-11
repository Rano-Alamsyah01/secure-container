
# Stage 1: Dependency Builder
FROM python:3.12-alpine AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-alpine

# Update seluruh package Alpine
RUN apk upgrade --no-cache

# Membuat user non-root
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

# Mengambil dependency dari builder
COPY --from=builder /install /usr/local

# Menyalin source code aplikasi
COPY --chown=appuser:appgroup app.py .

# Mengatur environment
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# Menjalankan aplikasi sebagai non-root
USER appuser

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health')" || exit 1

CMD ["python", "app.py"]
