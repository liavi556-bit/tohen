#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Check if .env file exists
if [ ! -f .env ]; then
  print_warning ".env file not found"
  
  if [ -f .env.example ]; then
    print_status "Creating .env from .env.example..."
    cp .env.example .env
    print_warning "⚠️  Please update .env file with your API keys before starting!"
    print_warning "Edit .env and add: ANTHROPIC_API_KEY, GOOGLE_API_KEY, OPENAI_API_KEY"
    exit 1
  else
    print_error ".env.example not found"
    exit 1
  fi
fi

# Parse command
case "$1" in
  "start")
    print_status "Starting Tohen services..."
    docker-compose up -d
    
    echo ""
    print_status "Services started!"
    echo ""
    echo "🌐 Frontend: http://localhost:3000"
    echo "🔌 Backend API: http://localhost:8000"
    echo "📚 API Docs: http://localhost:8000/docs"
    echo ""
    echo "View logs: docker-compose logs -f"
    ;;
  
  "stop")
    print_status "Stopping Tohen services..."
    docker-compose down
    ;;
  
  "restart")
    print_status "Restarting Tohen services..."
    docker-compose restart
    ;;
  
  "logs")
    docker-compose logs -f
    ;;
  
  "build")
    print_status "Building Tohen services..."
    docker-compose build --no-cache
    ;;
  
  "rebuild")
    print_status "Rebuilding and restarting Tohen services..."
    docker-compose down
    docker-compose build --no-cache
    docker-compose up -d
    echo ""
    print_status "Services rebuilt and running!"
    ;;
  
  "status")
    docker-compose ps
    ;;
  
  "clean")
    print_warning "This will remove all containers and volumes"
    read -p "Are you sure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      docker-compose down -v
      print_status "Cleaned up"
    fi
    ;;
  
  "backend-shell")
    docker-compose exec backend bash
    ;;
  
  "mongo-shell")
    docker-compose exec mongodb mongosh
    ;;
  
  "test")
    print_status "Running backend tests..."
    docker-compose exec backend pytest
    ;;
  
  *)
    echo "Tohen Docker Manager"
    echo ""
    echo "Usage: ./start.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start          - Start all services"
    echo "  stop           - Stop all services"
    echo "  restart        - Restart all services"
    echo "  rebuild        - Rebuild and restart services"
    echo "  logs           - View service logs"
    echo "  status         - Show service status"
    echo "  build          - Build images"
    echo "  clean          - Remove all containers and volumes"
    echo "  backend-shell  - Open bash in backend container"
    echo "  mongo-shell    - Open MongoDB shell"
    echo "  test           - Run backend tests"
    echo ""
    ;;
esac
