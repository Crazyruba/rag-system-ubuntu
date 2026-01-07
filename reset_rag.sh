#!/bin/bash
# Reset RAG system (keep documents)

cd ~/rag_system_ubuntu

# Stop services
./scripts/stop_rag.sh

# Backup documents
if [ -d "docs" ] && [ "$(ls -A docs)" ]; then
    mkdir -p backups
    cp -r docs backups/docs_backup_$(date +%Y%m%d_%H%M%S)
fi

# Remove AI database but keep documents
rm -rf vector_db
rm -rf data/cache
rm -f logs/*.log

# Recreate structure
mkdir -p vector_db data/cache

echo "✅ RAG system reset. Documents kept in backups/"
echo "📁 Start opnieuw met: ./scripts/start_rag.sh"