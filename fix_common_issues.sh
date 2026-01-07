#!/bin/bash
# Fix common Ubuntu RAG issues

echo "🔧 Fixing common issues..."

# 1. Permission issues
sudo chown -R $USER:$USER ~/rag_system_ubuntu
chmod +x ~/rag_system_ubuntu/scripts/*.sh

# 2. Python package issues
cd ~/rag_system_ubuntu
source venv/bin/activate
pip install --upgrade pip
pip install --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# 3. Port 8501 already in use
sudo lsof -ti:8501 | xargs kill -9 2>/dev/null || true

# 4. ChromaDB lock file
rm -f ~/rag_system_ubuntu/vector_db/*.lock 2>/dev/null || true

# 5. Clear cache
rm -rf ~/.cache/chroma ~/.cache/torch 2>/dev/null || true

echo "✅ Common issues fixed"