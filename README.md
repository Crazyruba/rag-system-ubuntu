# rag-system-ubuntu
# RAG System voor Ubuntu 24.04


# 🚀 RAG SYSTEM - Ubuntu 24.04 Snelstart

# 1️⃣ INSTALLATIE
 curl -sSL https://raw.githubusercontent.com/rag-install/scripts/main/ubuntu_install.sh | bash
 
# 2️⃣ CONFIGURATIE
 nano ~/rag_system_ubuntu/.env
# Voeg je API key toe: DEEPSEEK_API_KEY=sk-...

# 3️⃣ DOCUMENTEN
  cp /pad/naar/jouw/*.pdf ~/rag_system_ubuntu/docs/
  
# 4️⃣ STARTEN
  cd ~/rag_system_ubuntu
  ./scripts/start_rag.sh
  
# 5️⃣ BROWSER
  xdg-open http://localhost:8501

🛠️  HANDIGE COMMANDOS

# 📊 Status check
 ./scripts/status_rag.sh
 
# 🔄 Herstarten
 ./scripts/restart_rag.sh
 
# 📝 Logs bekijken
tail -f logs/rag_system_*.log

# 🗑️  Database resetten
 ./scripts/reset_rag.sh

# 🔄 Update systeem
 ./scripts/update_rag.sh

# 🗂️  Backup documenten
 ./scripts/backup_rag.sh

🆘 TROUBLESHOOTING

# Port conflict
sudo lsof -ti:8501 | xargs kill -9

# Python issues
pip install --upgrade -r requirements.txt

# ChromaDB error
rm -rf vector_db && mkdir vector_db

# Memory issues
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128

Na de Installatie:

# 1. Ga naar project
cd ~/rag_system_ubuntu

# 2. Bekijk configuratie
cat .env

# Bewerk met: nano .env

# 3. Test installatie
python test_installation.py

# 4. Start systeem
./scripts/start_rag.sh

# 5. Open browser
xdg-open http://localhost:8501

Run Script:

# Maak het script uitvoerbaar en run het
chmod +x install_rag.sh
./install_rag.sh

# OF voor directe installatie:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rag-install/scripts/main/ubuntu_install.sh)"


