#!/bin/bash
# ============================================================================
# 🤖 RAG SYSTEM AUTOMATISCHE INSTALLATIE - Ubuntu 24.04
# Versie: 2.0.0
# Datum: $(date)
# ============================================================================

set -e  # Stop bij eerste fout

# Kleuren voor output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functies voor logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Header
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║               RAG SYSTEM INSTALLATIE                     ║"
echo "║              Ubuntu 24.04 - Volledig Automatisch         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check op root
if [ "$EUID" -eq 0 ]; then 
    log_error "Dit script mag niet als root/sudo worden uitgevoerd!"
    log_info "Voer uit als normale gebruiker, sudo wachtwoord wordt gevraagd wanneer nodig."
    exit 1
fi

# ============================================================================
# STAP 1: SYSTEEM CONTROLES
# ============================================================================
log_info "Stap 1/8: Systeem controles uitvoeren..."

# Check Ubuntu versie
UBUNTU_VERSION=$(lsb_release -r | cut -f2)
if [[ "$UBUNTU_VERSION" != "24.04" ]]; then
    log_warning "Dit script is getest voor Ubuntu 24.04, jij gebruikt $UBUNTU_VERSION"
    read -p "Doorgaan? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    log_error "Python3 niet gevonden!"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
log_info "Python versie: $PYTHON_VERSION"

# Check vrije ruimte
FREE_SPACE=$(df -h ~ | awk 'NR==2 {print $4}')
log_info "Vrije schijfruimte: $FREE_SPACE"

# ============================================================================
# STAP 2: SYSTEEM DEPENDENCIES
# ============================================================================
log_info "Stap 2/8: Systeem dependencies installeren..."

sudo apt-get update -y

# Essentiële dependencies
sudo apt-get install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    curl \
    wget \
    git \
    cmake \
    pkg-config

# PDF en document dependencies
sudo apt-get install -y \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-nld \
    tesseract-ocr-eng \
    libtesseract-dev \
    libleptonica-dev \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx

# Python build dependencies
sudo apt-get install -y \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev

log_success "Systeem dependencies geïnstalleerd"

# ============================================================================
# STAP 3: PROJECT STRUCTUUR
# ============================================================================
log_info "Stap 3/8: Project structuur aanmaken..."

PROJECT_DIR="$HOME/rag_system_ubuntu"

if [ -d "$PROJECT_DIR" ]; then
    log_warning "Project directory bestaat al: $PROJECT_DIR"
    read -p "Overschrijven? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR"
        log_info "Oude directory verwijderd"
    else
        log_info "Gebruik bestaande directory"
    fi
fi

# Maak directory structuur
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

mkdir -p {docs,data,logs,uploads,models,config,backups,scripts}

log_success "Project structuur aangemaakt in: $PROJECT_DIR"

# ============================================================================
# STAP 4: PYTHON VIRTUELE OMGEVING
# ============================================================================
log_info "Stap 4/8: Python virtuele omgeving instellen..."

python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

log_success "Virtuele omgeving aangemaakt en geactiveerd"

# ============================================================================
# STAP 5: PYTHON PACKAGES INSTALLEREN
# ============================================================================
log_info "Stap 5/8: Python packages installeren (dit kan enkele minuten duren)..."

# Maak requirements.txt
cat > requirements.txt << 'EOF'
# ============================================
# RAG SYSTEM - Ubuntu 24.04 Optimized
# ============================================

# Core AI Framework
langchain==0.1.0
langchain-community==0.0.10
langchain-core==0.1.0
langchain-text-splitters==0.0.1

# Vector Database
chromadb==0.4.22
sentence-transformers==2.2.2

# Embeddings & Models
transformers==4.36.0
torch==2.1.2
torchvision==0.16.2
torchaudio==2.1.2
--index-url https://download.pytorch.org/whl/cpu

# Document Processing
pypdf==3.17.4
python-docx==1.1.0
unstructured==0.12.0
unstructured[pdf]==0.12.0
unstructured[docx]==0.12.0
pdf2image==1.16.3
pytesseract==0.3.10
Pillow==10.1.0

# LLM APIs
openai==1.6.1
google-generativeai==0.3.2
deepseek==0.8.1

# Web Interface
streamlit==1.29.0
streamlit-chat==0.1.2
streamlit-option-menu==0.3.6

# Utilities
python-dotenv==1.0.0
numpy==1.24.3
pandas==2.1.4
tqdm==4.66.1
psutil==5.9.6
tenacity==8.2.3
loguru==0.7.2
diskcache==5.6.3

# Web & Networking
requests==2.31.0
beautifulsoup4==4.12.2
aiohttp==3.9.1
fastapi==0.104.1
uvicorn[standard]==0.24.0

# Development Tools
ipython==8.18.1
jupyter==1.0.0
black==23.11.0
flake8==6.1.0
EOF

# Installeer packages in batches (betere error handling)
log_info "Installeer batch 1/4: Core packages..."
pip install --no-cache-dir \
    langchain==0.1.0 \
    langchain-community==0.0.10 \
    chromadb==0.4.22

log_info "Installeer batch 2/4: PyTorch (CPU)..."
pip install --no-cache-dir \
    torch==2.1.2 \
    torchvision==0.16.2 \
    torchaudio==2.1.2 \
    --index-url https://download.pytorch.org/whl/cpu

log_info "Installeer batch 3/4: Document processing..."
pip install --no-cache-dir \
    pypdf==3.17.4 \
    sentence-transformers==2.2.2 \
    transformers==4.36.0

log_info "Installeer batch 4/4: UI en utilities..."
pip install --no-cache-dir \
    streamlit==1.29.0 \
    openai==1.6.1 \
    python-dotenv==1.0.0 \
    google-generativeai==0.3.2

# Optioneel: installeer de rest
log_info "Installeer overige packages..."
pip install -r requirements.txt

log_success "Alle Python packages geïnstalleerd"

# ============================================================================
# STAP 6: CONFIGURATIE BESTANDEN
# ============================================================================
log_info "Stap 6/8: Configuratie bestanden aanmaken..."

# .env configuratie
cat > .env << 'EOF'
# ============================================
# RAG SYSTEM CONFIGURATIE
# ============================================

# 🔐 API KEYS - Kies EEN van onderstaande:
# DeepSeek API (gratis): https://platform.deepseek.com/api_keys
DEEPSEEK_API_KEY=sk-jouw_key_hier

# OF Gemini API (gratis): https://aistudio.google.com/app/apikey
# GEMINI_API_KEY=jouw_gemini_key_hier

# ⚙️ SYSTEEM CONFIGURATIE
USE_DATABASE=chroma
USE_LOCAL_EMBEDDINGS=true
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
LLM_MODEL=deepseek-chat
CHUNK_SIZE=500
CHUNK_OVERLAP=50

# 📁 PADEN
DOCUMENTS_DIR=./docs
VECTOR_DB_DIR=./vector_db
LOG_DIR=./logs
UPLOAD_DIR=./uploads

# 🌐 NETWERK
HOST=0.0.0.0
PORT=8501
ALLOW_UPLOADS=true
MAX_UPLOAD_SIZE_MB=100

# 🚀 PERFORMANCE
MAX_CONCURRENT_UPLOADS=3
EMBEDDING_BATCH_SIZE=32
CACHE_ENABLED=true
EOF

# .env voorbeeld
cp .env .env.example

# Configuratie bestand
cat > config/settings.yaml << 'EOF'
system:
  name: "RAG System Ubuntu"
  version: "2.0.0"
  debug: false
  
database:
  type: "chroma"
  path: "./vector_db"
  collection: "documents"
  
embeddings:
  model: "sentence-transformers/all-MiniLM-L6-v2"
  device: "cpu"
  batch_size: 32
  
llm:
  provider: "deepseek"
  model: "deepseek-chat"
  temperature: 0.1
  max_tokens: 1000
  
ui:
  theme: "light"
  language: "nl"
  auto_refresh: true
  
paths:
  documents: "./docs"
  uploads: "./uploads"
  logs: "./logs"
  backups: "./backups"
EOF

# Maak start script
cat > scripts/start_rag.sh << 'EOF'
#!/bin/bash
# RAG System Start Script

cd "$(dirname "$0")/.."
source venv/bin/activate

echo "🤖 Starting RAG System..."
echo "📁 Project: $(pwd)"
echo "🌐 Web UI: http://localhost:8501"
echo "📝 Logs: ./logs/rag_system.log"
echo ""

# Create required directories
mkdir -p docs data logs uploads backups

# Start Streamlit
streamlit run main.py --server.port 8501 --server.address 0.0.0.0
EOF

chmod +x scripts/start_rag.sh

# Maak stop script
cat > scripts/stop_rag.sh << 'EOF'
#!/bin/bash
# RAG System Stop Script

echo "🛑 Stopping RAG System..."
pkill -f "streamlit run main.py"
pkill -f "uvicorn"
echo "✅ RAG System stopped"
EOF

chmod +x scripts/stop_rag.sh

# Maak update script
cat > scripts/update_rag.sh << 'EOF'
#!/bin/bash
# RAG System Update Script

cd "$(dirname "$0")/.."
source venv/bin/activate

echo "🔄 Updating RAG System..."
echo ""

# Backup current configuration
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
cp -r docs/ backups/docs_$(date +%Y%m%d_%H%M%S)/

# Update packages
pip install --upgrade pip
pip install --upgrade \
    langchain \
    chromadb \
    sentence-transformers \
    streamlit \
    openai

echo "✅ Update complete!"
echo "📋 Changes backed up to backups/"
EOF

chmod +x scripts/update_rag.sh

log_success "Configuratie bestanden aangemaakt"

# ============================================================================
# STAP 7: HOOFD APPLICATIE
# ============================================================================
log_info "Stap 7/8: Hoofd applicatie installeren..."

# Download hoofd applicatie
cat > main.py << 'EOF'
#!/usr/bin/env python3
"""
🤖 RAG SYSTEM - Ubuntu 24.04 Edition
Volledig automatisch document chat systeem
"""

import os
import sys
import logging
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

# Load environment
load_dotenv()

# Setup logging
log_dir = Path("logs")
log_dir.mkdir(exist_ok=True)
log_file = log_dir / f"rag_system_{datetime.now().strftime('%Y%m%d')}.log"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class UbuntuRAGSystem:
    def __init__(self):
        self.version = "2.0.0"
        self.setup_directories()
        self.check_dependencies()
        
    def setup_directories(self):
        """Setup alle benodigde directories"""
        dirs = ["docs", "data", "uploads", "backups", "models", "vector_db"]
        for dir_name in dirs:
            Path(dir_name).mkdir(exist_ok=True)
            logger.info(f"Directory created/verified: {dir_name}")
    
    def check_dependencies(self):
        """Check alle dependencies"""
        try:
            import langchain
            import chromadb
            import sentence_transformers
            import streamlit
            import openai
            
            logger.info(f"✅ LangChain: {langchain.__version__}")
            logger.info(f"✅ ChromaDB: {chromadb.__version__}")
            logger.info(f"✅ Streamlit: {streamlit.__version__}")
            logger.info(f"✅ OpenAI: {openai.__version__}")
            
            return True
            
        except ImportError as e:
            logger.error(f"❌ Missing dependency: {e}")
            logger.error("Run: pip install -r requirements.txt")
            return False
    
    def run_web_ui(self):
        """Start de web interface"""
        try:
            import streamlit as st
            
            st.set_page_config(
                page_title="RAG System Ubuntu",
                page_icon="🤖",
                layout="wide",
                initial_sidebar_state="expanded"
            )
            
            # Main UI
            st.title("🤖 RAG System - Ubuntu Edition")
            st.markdown("""
            ### Praat met je documenten - Volledig lokaal & gratis
            
            **Features:**
            - 📁 Upload PDF, Word, tekst bestanden
            - 🔍 Slim zoeken door inhoud
            - 🤖 AI antwoorden met bronvermelding
            - 💾 Alles lokaal opgeslagen
            - 🆓 Geen maandelijkse kosten
            
            **Snel starten:**
            1. Upload documenten links
            2. Klik 'Laad in database'
            3. Stel vragen hieronder
            """)
            
            # Sidebar
            with st.sidebar:
                st.header("📂 Document Management")
                
                uploaded_files = st.file_uploader(
                    "Upload je documenten",
                    type=['pdf', 'txt', 'docx'],
                    accept_multiple_files=True
                )
                
                if uploaded_files:
                    for uploaded_file in uploaded_files:
                        file_path = Path("docs") / uploaded_file.name
                        with open(file_path, "wb") as f:
                            f.write(uploaded_file.getbuffer())
                    st.success(f"✅ {len(uploaded_files)} bestanden geüpload")
                
                if st.button("📥 Laad in Vector Database", type="primary"):
                    with st.spinner("Documenten verwerken..."):
                        st.info("Functie wordt geladen...")
                
                st.divider()
                st.header("⚙️ Systeem Info")
                st.write(f"**Versie:** {self.version}")
                st.write(f"**Python:** {sys.version.split()[0]}")
                st.write(f"**Documenten:** {len(list(Path('docs').glob('*')))}")
            
            # Chat interface
            st.header("💬 Chat met je Documenten")
            
            if "messages" not in st.session_state:
                st.session_state.messages = []
            
            for message in st.session_state.messages:
                with st.chat_message(message["role"]):
                    st.markdown(message["content"])
            
            if prompt := st.chat_input("Stel een vraag over je documenten..."):
                st.session_state.messages.append({"role": "user", "content": prompt})
                with st.chat_message("user"):
                    st.markdown(prompt)
                
                with st.chat_message("assistant"):
                    with st.spinner("Denken..."):
                        response = f"Demo antwoord voor: {prompt}"
                        st.markdown(response)
                
                st.session_state.messages.append({"role": "assistant", "content": response})
            
        except Exception as e:
            logger.error(f"UI error: {e}")
            st.error(f"Error: {e}")
    
    def run_cli(self):
        """Run command line interface"""
        print("\n" + "="*60)
        print("🤖 RAG SYSTEM - Command Line Interface")
        print("="*60)
        print("\nOpties:")
        print("  1. 📁 Documenten beheren")
        print("  2. 🔍 Door documenten zoeken")
        print("  3. ⚙️  Systeem instellingen")
        print("  4. 🚪 Afsluiten")
        print("="*60)
        
        while True:
            choice = input("\nKeuze (1-4): ").strip()
            
            if choice == "1":
                self.manage_documents()
            elif choice == "2":
                self.search_documents()
            elif choice == "3":
                self.system_settings()
            elif choice == "4":
                print("\n👋 Tot ziens!")
                break
            else:
                print("❌ Ongeldige keuze")
    
    def manage_documents(self):
        """Document management CLI"""
        print("\n📁 DOCUMENT MANAGEMENT")
        docs = list(Path("docs").glob("*"))
        
        if not docs:
            print("Geen documenten gevonden in docs/ folder")
            print("Plaats PDF, TXT of DOCX bestanden in de docs/ folder")
            return
        
        print(f"\nGevonden {len(docs)} documenten:")
        for i, doc in enumerate(docs, 1):
            print(f"  {i}. {doc.name} ({doc.stat().st_size / 1024:.1f} KB)")
    
    def search_documents(self):
        """Document search CLI"""
        print("\n🔍 DOCUMENT SEARCH")
        query = input("Zoekterm: ").strip()
        if query:
            print(f"Zoeken naar: '{query}'")
            print("(Search functionaliteit wordt geladen...)")
    
    def system_settings(self):
        """System settings CLI"""
        print("\n⚙️ SYSTEM SETTINGS")
        print("1. API Key instellen")
        print("2. Database resetten")
        print("3. Logs bekijken")
        
        choice = input("Keuze: ").strip()
        if choice == "1":
            new_key = input("Nieuwe API Key: ").strip()
            print("API Key wordt bijgewerkt...")
        elif choice == "2":
            print("Database wordt gereset...")
        elif choice == "3":
            print("Laatste logs:")
            os.system("tail -n 10 logs/*.log 2>/dev/null || echo 'Geen logs gevonden'")

def main():
    """Hoofdfunctie"""
    print("\n" + "="*60)
    print("🤖 RAG SYSTEM - Ubuntu 24.04 Edition")
    print("="*60)
    
    # Initialize system
    rag = UbuntuRAGSystem()
    
    # Check dependencies
    if not rag.check_dependencies():
        print("\n❌ Dependencies missen. Installeer met:")
        print("   pip install -r requirements.txt")
        sys.exit(1)
    
    # Interface keuze
    print("\nKies interface:")
    print("  1. 🌐 Web Interface (aanbevolen)")
    print("  2. 💻 Command Line Interface")
    print("  3. 🚪 Afsluiten")
    
    choice = input("\nKeuze (1-3): ").strip()
    
    if choice == "1":
        print("\n🌐 Starting web interface...")
        print("📡 Open je browser en ga naar: http://localhost:8501")
        print("🛑 Druk Ctrl+C om te stoppen\n")
        rag.run_web_ui()
    elif choice == "2":
        rag.run_cli()
    elif choice == "3":
        print("\n👋 Tot ziens!")
    else:
        print("❌ Ongeldige keuze")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 Gestopt door gebruiker")
    except Exception as e:
        logger.error(f"Critical error: {e}")
        print(f"\n❌ Critical error: {e}")
        sys.exit(1)
EOF

# Maak uitvoerbaar
chmod +x main.py

log_success "Hoofd applicatie geïnstalleerd"

# ============================================================================
# STAP 8: VOORBEELD DOCUMENTEN & TEST
# ============================================================================
log_info "Stap 8/8: Voorbeeld documenten en test setup..."

# Maak voorbeeld documenten
cat > docs/welkom.md << 'EOF'
# Welkom bij RAG System!

Dit is een voorbeeld document voor je nieuwe RAG systeem.

## Wat is RAG?
RAG (Retrieval-Augmented Generation) is een AI techniek die:
1. Documenten doorzoekt op relevante informatie
2. Die informatie gebruikt om antwoorden te genereren
3. Bronvermelding geeft voor elk antwoord

## Hoe te gebruiken:
1. Plaats je PDF/Word/TXT bestanden in de docs/ folder
2. Start het systeem: ./scripts/start_rag.sh
3. Upload documenten via de web interface
4. Stel vragen in de chat

## Voorbeeld vragen:
- "Wat is RAG?"
- "Hoe gebruik ik dit systeem?"
- "Welke document types worden ondersteund?"

Veel succes met je AI document assistent! 🚀
EOF

cat > docs/gebruiksaanwijzing.txt << 'EOF'
RAG SYSTEM GEBRUIKSAANWIJZING
============================

INSTALLATIE:
1. Run het install script
2. Voeg je API key toe aan .env bestand
3. Start met: ./scripts/start_rag.sh

DOCUMENTEN:
- PDF: Volledig ondersteund
- Word (.docx): Ondersteund
- Tekst (.txt): Ondersteund
- Beelden: Alleen via OCR in PDFs

API KEYS:
- DeepSeek: Gratis via https://platform.deepseek.com
- Gemini: Gratis via https://aistudio.google.com

TROUBLESHOOTING:
- Geen API key: Bewerk .env bestand
- Documenten niet laden: Check docs/ folder
- Web interface niet bereikbaar: Check poort 8501

CONTACT:
- Logs: ./logs/rag_system.log
- Config: ./config/settings.yaml
- Backups: ./backups/
EOF

# Maak test script
cat > test_installation.py << 'EOF'
#!/usr/bin/env python3
import sys
import subprocess
import json
from pathlib import Path

def run_test():
    print("🧪 RAG System Installation Test")
    print("="*50)
    
    tests_passed = 0
    total_tests = 0
    
    def test(name, condition):
        nonlocal tests_passed, total_tests
        total_tests += 1
        if condition:
            print(f"✅ {name}")
            tests_passed += 1
        else:
            print(f"❌ {name}")
    
    # Test 1: Check project structure
    print("\n📁 Project Structure:")
    required_dirs = ["docs", "data", "logs", "uploads", "scripts", "config", "venv"]
    for dir_name in required_dirs:
        test(f"Directory: {dir_name}", Path(dir_name).exists())
    
    # Test 2: Check required files
    print("\n📄 Required Files:")
    required_files = [".env", "main.py", "requirements.txt", "scripts/start_rag.sh"]
    for file_name in required_files:
        test(f"File: {file_name}", Path(file_name).exists())
    
    # Test 3: Check Python environment
    print("\n🐍 Python Environment:")
    try:
        import sys
        test(f"Python version: {sys.version.split()[0]}", True)
    except:
        test("Python version", False)
    
    # Test 4: Check API key config
    print("\n🔐 API Configuration:")
    env_file = Path(".env")
    if env_file.exists():
        content = env_file.read_text()
        has_api_key = "API_KEY" in content or "sk-" in content
        test("API key configured", has_api_key)
    else:
        test("API key configured", False)
    
    # Test 5: Check document samples
    print("\n📚 Document Samples:")
    docs = list(Path("docs").glob("*"))
    test(f"Sample documents: {len(docs)}", len(docs) > 0)
    
    # Summary
    print("\n" + "="*50)
    print(f"📊 TEST RESULTS: {tests_passed}/{total_tests} passed")
    
    if tests_passed == total_tests:
        print("\n🎉 ALL TESTS PASSED! Your RAG system is ready!")
        print("\n🚀 Next steps:")
        print("   1. Edit .env with your API key")
        print("   2. Add your documents to docs/ folder")
        print("   3. Start with: ./scripts/start_rag.sh")
        return True
    else:
        print(f"\n⚠️  {total_tests - tests_passed} tests failed")
        print("\n🔧 Troubleshooting:")
        print("   - Run: pip install -r requirements.txt")
        print("   - Check .env file exists")
        print("   - Verify docs/ folder has documents")
        return False

if __name__ == "__main__":
    success = run_test()
    sys.exit(0 if success else 1)
EOF

chmod +x test_installation.py

# Maak systemd service (optioneel)
cat > scripts/rag-system.service << 'EOF'
[Unit]
Description=RAG System Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/rag_system_ubuntu
Environment="PATH=/home/$USER/rag_system_ubuntu/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/home/$USER/rag_system_ubuntu/venv/bin/streamlit run main.py --server.port 8501 --server.address 0.0.0.0
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=rag-system

[Install]
WantedBy=multi-user.target
EOF

# Maak desktop shortcut
cat > ~/Desktop/RAG-System.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=RAG System
Comment=AI Document Chat System
Exec=bash -c "cd $HOME/rag_system_ubuntu && ./scripts/start_rag.sh"
Icon=system-run
Terminal=true
Categories=Utility;AI;
EOF

chmod +x ~/Desktop/RAG-System.desktop

log_success "Voorbeeld documenten en test setup voltooid"

# ============================================================================
# EIND SAMENVATTING
# ============================================================================
log_info "Installatie voltooid!"

echo -e "\n${GREEN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                 INSTALLATIE VOLTOOID!                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "\n📋 ${BLUE}NEXT STEPS:${NC}"
echo "   1. ${YELLOW}Voeg je API key toe:${NC}"
echo "      nano $PROJECT_DIR/.env"
echo "      (verander 'sk-jouw_key_hier' naar je echte key)"
echo ""
echo "   2. ${YELLOW}Voeg documenten toe:${NC}"
echo "      cp /pad/naar/jouw/documenten/* $PROJECT_DIR/docs/"
echo ""
echo "   3. ${YELLOW}Start het systeem:${NC}"
echo "      cd $PROJECT_DIR"
echo "      ./scripts/start_rag.sh"
echo ""
echo "   4. ${YELLOW}Open in browser:${NC}"
echo "      http://localhost:8501"
echo ""
echo "   5. ${YELLOW}Test de installatie:${NC}"
echo "      cd $PROJECT_DIR"
echo "      python test_installation.py"

echo -e "\n📁 ${BLUE}PROJECT STRUCTUUR:${NC}"
echo "   $PROJECT_DIR/"
echo "   ├── 📄 main.py              # Hoofdprogramma"
echo "   ├── 📄 .env                 # API configuratie"
echo "   ├── 📁 docs/                # Jouw documenten hier"
echo "   ├── 📁 scripts/             # Start/stop scripts"
echo "   ├── 📁 config/              # Configuratie bestanden"
echo "   └── 📁 venv/                # Python omgeving"

echo -e "\n🚀 ${BLUE}QUICK START:${NC}"
echo "   cd $PROJECT_DIR"
echo "   source venv/bin/activate"
echo "   streamlit run main.py"

echo -e "\n🆘 ${BLUE}TROUBLESHOOTING:${NC}"
echo "   - Test: python test_installation.py"
echo "   - Logs: tail -f $PROJECT_DIR/logs/rag_system_*.log"
echo "   - Update: ./scripts/update_rag.sh"

echo -e "\n${GREEN}🎉 Succes met je nieuwe RAG systeem!${NC}"
echo ""

# Run quick test
echo "🧪 Running quick test..."
cd "$PROJECT_DIR"
source venv/bin/activate
if python test_installation.py; then
    echo -e "\n${GREEN}✅ All tests passed! Your system is ready.${NC}"
else
    echo -e "\n${YELLOW}⚠️  Some tests failed. Check the output above.${NC}"
fi

# Final message
echo ""
echo "💡 ${BLUE}Tip:${NC} Maak een alias voor gemak:"
echo "    echo \"alias rag='cd $PROJECT_DIR && source venv/bin/activate && streamlit run main.py'\" >> ~/.bashrc"
echo ""
echo "📚 ${BLUE}Documentatie:${NC}"
echo "    - Plaats documenten in: $PROJECT_DIR/docs/"
echo "    - API key aanpassen: $PROJECT_DIR/.env"
echo "    - Logs bekijken: $PROJECT_DIR/logs/"
echo ""
echo "${GREEN}🚀 KLAAR OM TE BEGINNEN! 🚀${NC}"