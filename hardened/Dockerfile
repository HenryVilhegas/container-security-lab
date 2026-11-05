# HARDENED: multi-stage, base slim, usuário não-root, servidor WSGI de produção.
FROM python:3.12-slim AS builder
WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY --from=builder /install /usr/local
WORKDIR /app
COPY app/app.py .

# UID fixo e numérico (necessário para runAsNonRoot no Kubernetes)
RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin appuser
USER 10001:10001

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request as u; u.urlopen('http://127.0.0.1:8080/health')" || exit 1
CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app"]
