# INSEGURO (de propósito): imagem completa e antiga, roda como root, sem healthcheck.
FROM python:3.9

WORKDIR /app
COPY app/requirements.txt .
RUN pip install -r requirements.txt
COPY app/ .

EXPOSE 8080
# Servidor de desenvolvimento do Flask, rodando como root
CMD ["python", "app.py"]
