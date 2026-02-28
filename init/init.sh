#!/bin/bash
set -e

echo "Checking database initialization..."

# Give PostgreSQL time to start
sleep 3

# Check if knowledge_base table exists
TABLE_CHECK=$(psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tc "SELECT 1 FROM information_schema.tables WHERE table_name='knowledge_base';" 2>/dev/null || echo "")

if [ -z "$TABLE_CHECK" ]; then
    echo "Tables not found, initializing database..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/local_rag_setup.sql
    echo "Database initialized successfully"
else
    echo "Tables already exist, skipping initialization"
fi

# Verify final state
echo ""
echo "Database Status:"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT version();"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT extname FROM pg_extension WHERE extname='vector';" && echo "pgvector extension installed" || echo " pgvector not found"
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tc "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;" && echo "Tables created" || echo " No tables found"
