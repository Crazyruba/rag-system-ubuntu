#!/bin/bash
# install_wizard.sh

echo "🎮 RAG System Installatie Wizard"
echo "================================="

# Stap 1: Keuze
echo ""
echo "Kies installatie type:"
echo "  1. Volledig (aanbevolen)"
echo "  2. Minimal (alleen basics)"
echo "  3. Custom"
read -p "Keuze (1-3): " INSTALL_TYPE

# Stap 2: API key
echo ""
read -p "Heb je al een DeepSeek API key? (y/N): " HAS_KEY
if [[ $HAS_KEY =~ ^[Yy]$ ]]; then
    read -p "Voer je API key in: " API_KEY
else
    echo ""
    echo "📝 Maak een gratis API key aan:"
    echo "  1. Ga naar: https://platform.deepseek.com/"
    echo "  2. Maak account (gratis)"
    echo "  3. Ga naar API Keys"
    echo "  4. Klik 'Create API Key'"
    echo "  5. Kopieer de key (begint met sk-...)"
    echo ""
    read -p "Voer API key in (of druk Enter om later in te stellen): " API_KEY
fi

# Stap 3: Download en run
echo ""
echo "📥 Downloaden installatie script..."
curl -sSL -o /tmp/rag_install.sh https://raw.githubusercontent.com/rag-install/scripts/main/ubuntu_install.sh
chmod +x /tmp/rag_install.sh

echo "🚀 Installatie starten..."
bash /tmp/rag_install.sh

# Stap 4: Configure API key
if [ -n "$API_KEY" ]; then
    echo "⚙️ API key configureren..."
    sed -i "s/sk-jouw_key_hier/$API_KEY/" ~/rag_system_ubuntu/.env
fi

echo ""
echo "🎉 Installatie voltooid!"
echo "🌐 Start met: cd ~/rag_system_ubuntu && ./scripts/start_rag.sh"