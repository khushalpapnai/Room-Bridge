Room-Bridge

AI-powered room-rental discovery platform that combines personalized ranking, verified listings, and real-time communication to make finding rental rooms faster, safer and more relevant for students and professionals.

## Key Features

- Personalized ranking and recommendations (ML-based)
- Verified listings and document upload/approval workflow
- Real-time chat between tenants and owners
- Advanced search and filters (location, price, amenities)
- Review and sentiment analysis to improve reliability
- Admin dashboard for verification and moderation

## Tech Stack

- Frontend: React (TypeScript), Vite, Tailwind CSS
- Backend: Java Spring Boot (REST API, WebSocket)
- Database: MySQL, Redis (cache)
- Search: Elasticsearch (optional, for geospatial & text search)
- ML / Ranking: Python, scikit-learn, VADER (sentiment)
- Image/diagram generator (optional): Diffusers / Stable Diffusion + Gradio
- DevOps: Docker, Docker Compose, optional Kubernetes

## Repository Layout

```
Room-Bridge/
├── backend/        # Java Spring Boot API and services
├── frontend/       # React + TypeScript web client
├── ranking/        # Python ML/ranking code and models
├── documents/      # Project docs (including project_documentation.txt)
└── README.md       # This file
```

## Quickstart (development)

Prerequisites: Java 17+, Maven, Node.js (16+/18+), Python 3.10+, Docker (optional)

1. Install frontend dependencies and run dev server

```powershell
cd frontend
npm install
npm run dev
# Frontend available at http://localhost:5173
```

2. Build & run backend (Spring Boot)

```powershell
cd backend
./mvnw clean package
./mvnw spring-boot:run
# Backend default: http://localhost:8080
```

3. Run ranking service (local Python)

```powershell
cd ranking
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python app.py
# Ranking service default: http://localhost:8000
```

4. Run everything with Docker Compose (recommended for local integration)

```powershell
docker-compose up --build
```

## Configuration

- Frontend expects API URLs in environment (Vite) — check `vite.config.ts` and `src/services/api.ts`.
- Backend configuration is in `backend/src/main/resources/application.properties`.
- Ranking service configuration is in `ranking/config.py` / environment variables.

## Testing

- Frontend: run unit / e2e tests according to `package.json` scripts.
- Backend: `./mvnw test` runs unit/integration tests.
- ML: `pytest` inside the `ranking` folder for model and utility tests.

## Deployment notes

- Build images for each component and push to a registry (ECR/GCR/Docker Hub).
- Use Docker Compose for small deployments or Kubernetes for production-scale.
- The project supports deploying the diagram/image generator as a separate Hugging Face Space or Gradio service (GPU recommended).



## Contributing

1. Fork the repo
2. Create a feature branch
3. Run tests and linters locally
4. Open a pull request with a clear description and related issue




