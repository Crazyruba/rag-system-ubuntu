#!/bin/bash
# Post-installatie configuratie

echo "⚙️ Post-installatie configuratie..."

# 1. Zet API key
read -p "📝 Voer je DeepSeek API key in (sk-...): " API_KEY
if [ -n "$API_KEY" ]; then
    sed -i "s/sk-jouw_key_hier/$API_KEY/" ~/rag_system_ubuntu/.env
    echo "✅ API key ingesteld"
fi

# 2. Maak desktop shortcut
echo "[Desktop Entry]
Name=RAG System
Comment=AI Document Assistant
Exec=bash -c 'cd ~/rag_system_ubuntu && ./scripts/start_rag.sh'
Icon=applications-other
Terminal=true
Type=Application" > ~/Desktop/RAG-System.desktop

chmod +x ~/Desktop/RAG-System.desktop

# 3. Maak alias
echo "alias rag='cd ~/rag_system_ubuntu && source venv/bin/activate && streamlit run main.py'" >> ~/.bashrc

# 4. Start services
echo "🚀 Starting RAG System..."
cd ~/rag_system_ubuntu
./scripts/start_rag.sh &
sleep 3

echo ""
echo "✅ Configuratie voltooid!"
echo "🌐 Open browser naar: http://localhost:8501"
echo "📁 Documenten plaatsen: ~/rag_system_ubuntu/docs/"