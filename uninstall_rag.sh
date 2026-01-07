#!/bin/bash
# uninstall_rag.sh

echo "🗑️ RAG System verwijderen..."

PROJECT_DIR="$HOME/rag_system_ubuntu"

# Stop running services
pkill -f "streamlit run main.py" 2>/dev/null || true

# Verwijder project directory
if [ -d "$PROJECT_DIR" ]; then
    read -p "Verwijder $PROJECT_DIR? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
        echo "✅ Project directory verwijderd"
    fi
fi

# Verwijder desktop shortcut
rm -f ~/Desktop/RAG-System.desktop 2>/dev/null

# Verwijder alias uit .bashrc
sed -i '/alias rag=/d' ~/.bashrc 2>/dev/null

# Verwijder systemd service
sudo systemctl stop rag-system 2>/dev/null || true
sudo systemctl disable rag-system 2>/dev/null || true
sudo rm -f /etc/systemd/system/rag-system.service 2>/dev/null

echo "✅ RAG System volledig verwijderd"