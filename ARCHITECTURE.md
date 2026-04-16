# 🏗️ Tohen Architecture & Technical Documentation

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User's Browser                               │
│                      (React Application)                             │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │    Nginx Reverse        │
                    │    Proxy (Port 80/443)  │
                    └────────────┬────────────┘
                    ┌────────────▼────────────┐
                    │   Load Balancing        │
                    │   Rate Limiting         │
                    │   SSL Termination       │
                    └────────┬────────────┬───┘
                             │            │
            ┌────────────────▼──┐    ┌────▼──────────────┐
            │ Frontend Service   │    │ Backend Service   │
            │ (Node.js/React)    │    │ (Python/FastAPI)  │
            │ Port 3000          │    │ Port 8000         │
            └────────────────────┘    └────┬──────────────┘
                                            │
                                    ┌───────▼────────┐
                                    │ MongoDB        │
                                    │ Port 27017     │
                                    └────────────────┘
```

---

## Technology Stack

### Frontend
- **Framework**: React 19
- **Styling**: Tailwind CSS + PostCSS
- **Build Tool**: Craco (Create React App Override)
- **UI Components**: Radix UI, Shadcn/ui
- **State Management**: React Hooks
- **HTTP Client**: Axios
- **Routing**: React Router v7
- **Icons**: Lucide React
- **Charts**: Recharts
- **Forms**: React Hook Form + Zod
- **Container**: Node.js 20 Alpine
- **Package Manager**: Yarn

### Backend
- **Framework**: FastAPI 0.110.1
- **Web Server**: Uvicorn (development) / Gunicorn (production)
- **Language**: Python 3.11
- **Database**: MongoDB 7.0 with Motor (async driver)
- **API Style**: REST with JSON
- **Authentication**: JWT (python-jose)
- **Validation**: Pydantic v2
- **Async**: AsyncIO
- **AI Integrations**:
  - Anthropic API
  - Google Generative AI
  - OpenAI API
- **Additional Libraries**: 
  - google-ai-generativelanguage
  - litellm (LLM routing)
  - youtube-transcript-api

### Database
- **MongoDB 7.0** - NoSQL document database
- **Collections**: 
  - Content items
  - Chat sessions
  - User data
  - Strategist interactions
- **Backup**: Via mongodump/mongorestore
- **Replication**: Standalone (can be upgraded to replica set)

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Reverse Proxy**: Nginx
- **Orchestration**: Docker Compose (development/production)
- **CI/CD**: GitHub Actions
- **Registry**: Docker Hub / GHCR

---

## Project Structure

```
tohen-main/
├── frontend/                    # React application
│   ├── src/
│   │   ├── components/         # Reusable React components
│   │   ├── pages/              # Page-level components
│   │   ├── hooks/              # Custom React hooks
│   │   ├── services/           # API service calls (Axios)
│   │   └── App.jsx             # Root component
│   ├── public/                 # Static assets
│   ├── package.json            # Dependencies
│   ├── Dockerfile              # Development image
│   ├── Dockerfile.prod         # Production image
│   ├── tailwind.config.js      # Tailwind CSS config
│   └── craco.config.js         # Craco override config
│
├── backend/                     # Python FastAPI application
│   ├── server.py               # Main application & routes
│   ├── ai_provider.py          # AI service integrations
│   ├── requirements.txt         # Python dependencies
│   ├── Dockerfile              # Development image
│   ├── Dockerfile.prod         # Production image
│   ├── .env                    # Environment variables
│   └── tests/                  # Test suite
│
├── docker-compose.yml          # Development compose file
├── docker-compose.prod.yml     # Production compose file
├── nginx.conf                  # Nginx reverse proxy config
├── DOCKER_SETUP.md             # Docker setup guide
├── DEPLOYMENT_GUIDE.md         # Deployment instructions
├── health-check.sh             # Health monitoring script
├── start.sh                    # Docker management script
├── .env.example                # Environment template
├── .env.production             # Production environment template
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions pipeline
└── README.md                   # Project overview
```

---

## Data Flow

### Content Creation Flow

```
User Input (Frontend)
    ↓
React Form Component
    ↓
Axios HTTP Request
    ↓
[Nginx Reverse Proxy]
    ↓
FastAPI Endpoint (@api_router.post("/content"))
    ↓
Pydantic Validation
    ↓
MongoDB Insert
    ↓
JSON Response
    ↓
React State Update
    ↓
UI Render
```

### AI Integration Flow

```
User Message
    ↓
Backend Route Handler
    ↓
ai_chat() Function
    ↓
(Choose Provider: Anthropic/Google/OpenAI)
    ↓
LLM API Call
    ↓
Response Generation
    ↓
MongoDB Save Chat History
    ↓
Return to Frontend
    ↓
Display in UI
```

---

## API Endpoints

### Content Management
- `GET /api/content` - List all content
- `GET /api/content/{id}` - Get single content
- `POST /api/content` - Create content
- `PUT /api/content/{id}` - Update content
- `DELETE /api/content/{id}` - Delete content
- `GET /api/folders` - Get folder structure

### AI Interactions
- `POST /api/agents/strategist/chat` - Chat with strategist AI
- `GET /api/agents/strategist/sessions` - List chat sessions
- `GET /api/agents/strategist/chat/{session_id}` - Get session history
- `DELETE /api/agents/strategist/session/{session_id}` - Delete session

### YouTube Processing
- `POST /api/youtube/process` - Process YouTube video

### Health & Status
- `GET /docs` - API documentation (Swagger UI)
- `GET /redoc` - API documentation (ReDoc)
- `GET /openapi.json` - OpenAPI schema

---

## Environment Variables

### Backend Required
```
MONGO_URL=mongodb://mongodb:27017/tohen
DB_NAME=tohen
CORS_ORIGINS=http://localhost:3000
ANTHROPIC_API_KEY=sk-...
GOOGLE_API_KEY=...
OPENAI_API_KEY=sk-...
```

### Frontend Required
```
REACT_APP_API_URL=http://localhost:8000
REACT_APP_API_INTERNAL=http://backend:8000
```

### Optional
```
LOG_LEVEL=info
WORKERS=4
MONGO_USER=admin
MONGO_PASSWORD=password
```

---

## Database Schema

### Content Collection
```javascript
{
  _id: ObjectId,
  id: string,
  title: string,
  content: string,
  folder_id: string,
  source_type: "manual" | "youtube" | "voice",
  youtube_url: string | null,
  created_at: ISO8601,
  updated_at: ISO8601
}
```

### Chat Sessions Collection
```javascript
{
  _id: ObjectId,
  id: string,
  session_id: string,
  user_message: string,
  assistant_message: string,
  created_at: ISO8601
}
```

---

## Deployment Architecture

### Development
```
docker-compose up -d
├── MongoDB (localhost:27017)
├── Backend (localhost:8000)
└── Frontend (localhost:3000)
```

### Production
```
docker-compose -f docker-compose.prod.yml up -d
├── Nginx Reverse Proxy (Port 80/443)
├── MongoDB (Internal network, port 27017)
├── Backend (Internal network, port 8000)
└── Frontend (Internal network, port 3000)
```

### Cloud Deployment
```
Load Balancer (if scaling)
    ↓
Nginx (reverse proxy + SSL)
    ↓
├── Backend Cluster (multiple instances)
├── Frontend Cluster (multiple instances)
└── MongoDB (managed database)
```

---

## Security Considerations

### Network Security
- ✅ Nginx reverse proxy filters requests
- ✅ CORS configured to specific origins
- ✅ Rate limiting on API endpoints
- ✅ SSL/TLS encryption (nginx)

### Data Security
- ✅ MongoDB authentication (username/password)
- ✅ API key validation on every request
- ✅ Input validation via Pydantic
- ✅ SQL injection protection (using MongoDB)

### Container Security
- ✅ Minimal base images (alpine, slim)
- ✅ Non-root user execution
- ✅ Health checks enabled
- ✅ Resource limits configurable

### Recommended Additions
- [ ] API rate limiting (implement in FastAPI)
- [ ] Request logging & monitoring
- [ ] Secrets management (HashiCorp Vault)
- [ ] Regular security audits
- [ ] Database encryption at rest

---

## Performance Optimization

### Frontend
- Lazy loading components
- Code splitting via React.lazy()
- Image optimization with next-image patterns
- CSS minification via Tailwind
- Caching strategies via service workers (PWA)

### Backend
- Connection pooling for MongoDB
- Async operations throughout
- Request caching headers
- Gzip compression (via Nginx)
- Response pagination

### Database
- Index optimization
- Connection pooling
- Aggregation pipeline optimization
- Compound indexes for frequently queried fields

### Infrastructure
- Load balancing via Nginx
- Container resource limits
- Auto-scaling via Kubernetes (if needed)
- CDN for static assets

---

## Monitoring & Logging

### Application Logs
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Health Checks
```bash
./health-check.sh
```

### Performance Metrics
- Response time monitoring
- Error rate tracking
- Database query performance
- API endpoint usage statistics

### Recommended Tools
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **ELK Stack** - Log aggregation
- **Datadog** - APM & monitoring
- **New Relic** - Performance monitoring

---

## Scaling Strategy

### Vertical Scaling
- Increase container resource limits
- Upgrade MongoDB instance
- Use larger server sizes

### Horizontal Scaling
- Multiple backend instances behind load balancer
- MongoDB replica set for replication
- Nginx load balancing across backends
- Redis for session caching (optional)

### Database Scaling
- MongoDB sharding for large datasets
- Read replicas for scaling reads
- Backup replication across regions

---

## Backup & Disaster Recovery

### Backup Strategy
```bash
# Daily MongoDB backups
*/daily backup-mongodb.sh

# Backup retention: 30 days
# Backup location: /backups/mongodb/
# Restore: mongorestore --archive=backup_file
```

### Disaster Recovery Plan
1. **Recovery Time Objective (RTO)**: 1 hour
2. **Recovery Point Objective (RPO)**: 24 hours
3. **Backup location**: Off-site storage (S3, GCS)
4. **Regular testing**: Monthly restore tests

---

## Development Workflow

### Local Development
```bash
./start.sh start          # Start services
# Edit code
docker-compose logs -f    # Monitor logs
./start.sh stop          # Stop services
```

### Testing
```bash
./start.sh test          # Run pytest backend tests
# Frontend tests: npm test
```

### Deployment
```bash
git push main
# GitHub Actions triggers CI/CD
# Tests run automatically
# Images built and pushed
# Manual approval for prod deployment
```

---

## Useful Commands Reference

### Docker Management
```bash
docker-compose ps                    # Container status
docker-compose logs -f [service]     # View logs
docker-compose exec [service] bash   # Shell access
docker-compose build --no-cache      # Rebuild images
```

### Database Operations
```bash
docker-compose exec mongodb mongosh  # MongoDB shell
docker-compose exec mongodb mongodump  # Backup
docker-compose exec mongodb mongorestore  # Restore
```

### Health & Monitoring
```bash
./health-check.sh                    # Full health check
curl http://localhost:8000/docs      # API documentation
curl http://localhost:3000           # Frontend check
```

---

## Troubleshooting Guide

### Issue: Port Already in Use
```bash
# Find process using port
lsof -i :8000
# Kill process
kill -9 PID
# Or change port in docker-compose.yml
```

### Issue: MongoDB Connection Failed
```bash
# Check MongoDB is running
docker-compose ps mongodb
# Check logs
docker-compose logs mongodb
# Reset database
docker-compose down -v
docker-compose up -d
```

### Issue: High Memory Usage
```bash
# Check container resource usage
docker stats
# Set limits in docker-compose.yml
# Restart containers
docker-compose restart
```

---

## Future Enhancements

- [ ] Kubernetes deployment config (k8s manifests)
- [ ] Terraform infrastructure as code
- [ ] Advanced caching with Redis
- [ ] Message queue (RabbitMQ/Kafka) for async tasks
- [ ] WebSocket support for real-time updates
- [ ] GraphQL API as alternative to REST
- [ ] Multi-region deployment
- [ ] Advanced analytics & reporting

---

## References & Resources

- [Docker Documentation](https://docs.docker.com)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [React Documentation](https://react.dev)
- [MongoDB Documentation](https://docs.mongodb.com)
- [Nginx Documentation](https://nginx.org/en/docs)

---

**For detailed setup instructions, see `DOCKER_SETUP.md`**
**For deployment instructions, see `DEPLOYMENT_GUIDE.md`**
