# Use a smaller Python runtime image.
FROM python:3.12-slim

# Configure Python for container execution.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Create a dedicated, unprivileged runtime user.
RUN groupadd --system appgroup \
    && useradd --system \
       --gid appgroup \
       --home-dir /app \
       --no-create-home appuser

# Copy dependencies separately to preserve build caching.
COPY app/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir \
    -r /app/requirements.txt

# Copy only the application files.
COPY --chown=appuser:appgroup app/ /app/app/

# Drop root privileges.
USER appuser

# Document the application port.
EXPOSE 8080

# Start the application using Gunicorn.
CMD ["gunicorn", "--chdir", "app", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]