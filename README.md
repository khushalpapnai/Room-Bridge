# Room Bridge - Room Rental & Roommate Finder Platform

## Overview
Room Bridge is a **comprehensive room rental and roommate finder platform** built with modern web technologies. It connects room seekers with landlords/owners, facilitating easy room discovery, booking, and communication. The platform includes advanced features like room reviews, document verification, chat messaging, and admin dashboard for moderation.

## 🎯 Key Features

- **Room Listings**: Browse and search for available rooms with detailed information
- **User Authentication**: Secure login, signup, and OTP-based email verification
- **Room Management**: Create, edit, and manage room listings with images
- **Direct Chat**: Real-time communication between users and room owners
- **Reviews & Ratings**: Rate properties and read other user reviews
- **Document Verification**: Upload and manage verification documents
- **Admin Dashboard**: Comprehensive admin panel for user and room management
- **Profile Management**: Customize user profiles with social links and bio
- **Search & Filters**: Advanced search capabilities by location and preferences

## 🛠 Tech Stack

### Backend
- **Spring Boot** - Java framework for REST API
- **MySQL** - Relational database
- **JWT** - Secure authentication tokens
- **Hibernate/JPA** - ORM for database operations
- **Spring Security** - Authentication/Authorization

### Frontend
- **React** - UI framework
- **TypeScript** - Type-safe JavaScript
- **Tailwind CSS** - Utility-first CSS framework
- **Vite** - Fast build tool
- **Axios** - HTTP client for API calls

### Additional Services
- **Redis** - Session/Cache management
- **Docker** - Containerization

---

## 📸 Platform Screenshots

### Home Page
<code title="Home"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/homePage.jpg"></code>

### Login Page  
<code title="Login"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/loginPage.jpg"></code>

### Account Creation
<code title="Sign Up"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/createAccPage.jpg"></code>

### Featured Rooms
<code title="Featured"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/featureRoomPage.jpg"></code>

### All Rooms Listing
<code title="All Rooms"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/allRoomPage.jpg"></code>

### Room Details
<code title="Room Details"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/roomPage.jpg"></code>

### Create New Room
<code title="Create Room"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/createRoomPage.jpg"></code>

### New Room Listing
<code title="New Room"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/newRoomPage.jpg"></code>

### Direct Chat
<code title="Chat"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/chatPage.jpg"></code>

### Document Verification
<code title="Documents"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/documentPage.jpg"></code>

### Admin Dashboard
<code title="Admin"><img height="250" src="https://github.com/AkshatJMe/Room-Bridge/blob/main/screenshots/adminDashboard.jpg"></code>

---

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Node.js 16+ (for frontend)
- Java 11+ (optional, if running backend without Docker)
- MySQL 8.0+ (if running locally)

### Quick Start

#### 1. Start MySQL & Redis Containers
```bash
cd backend
docker compose up -d
docker run -d -p 6379:6379 --name redis redis
```

#### 2. Seed Test Data
```bash
docker exec -i roomy-mysql mysql -uroot -proot < seed_loadtest_data.sql
```

#### 3. Start Frontend (Development)
```bash
cd frontend
npm install
npm run dev
```

#### 4. Backend (via Docker or Maven)
```bash
# Using Docker Compose
cd backend
docker compose -f docker-compose.yml up -d

# OR manually with Maven
mvn spring-boot:run
```

Access the application at `http://localhost:3000` (frontend) and `http://localhost:8081` (backend API).

---

## 📁 Project Structure

```
Room-Bridge/
├── backend/
│   ├── src/main/java/roomy/
│   │   ├── controller/      # REST API endpoints
│   │   ├── service/         # Business logic
│   │   ├── entities/        # Database models
│   │   ├── dto/             # Data transfer objects
│   │   ├── repositories/    # Data access layer
│   │   └── config/          # Application configuration
│   ├── docker-compose.yml   # MySQL & Docker setup
│   └── seed_loadtest_data.sql # Test data seeding
│
├── frontend/
│   ├── src/
│   │   ├── pages/           # Page components
│   │   ├── components/      # Reusable components
│   │   ├── services/        # API client
│   │   ├── types/           # TypeScript types
│   │   └── contexts/        # React context
│   ├── vite.config.ts       # Vite configuration
│   └── tailwind.config.js   # Tailwind CSS
│
├── ranking/
│   ├── app.py               # Ranking algorithm service
│   └── models/              # ML models for ranking
│
├── documents/               # Project documentation
├── screenshots/             # UI screenshots
└── README.md                # This file
```

---

## 🔑 Key Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/verify-otp` - OTP verification
- `POST /api/auth/forgot-password` - Password reset

### Rooms
- `GET /api/room` - Get all rooms
- `POST /api/room` - Create new room
- `GET /api/room/{id}` - Get room details
- `PUT /api/room/{id}` - Update room
- `DELETE /api/room/{id}` - Delete room
- `GET /api/room/search?location=` - Search rooms by location

### Reviews
- `POST /api/room-review` - Add room review
- `GET /api/room-review/{roomId}` - Get room reviews

### Chat
- `GET /api/chat/messages/{userId}` - Get messages
- `POST /api/chat/send` - Send message

### Admin
- `GET /api/admin/users` - List all users
- `GET /api/admin/rooms` - List all rooms
- `DELETE /api/admin/room/{id}` - Delete room
- `POST /api/admin/verify-document` - Verify user documents

---

## 🔐 Authentication Flow

1. User registers with email and password
2. OTP sent to email for verification
3. On verification, account is activated
4. JWT token issued for authenticated requests
5. Refresh tokens managed via Redis sessions

---

## 📊 Database Schema

### Core Entities
- **User** - User accounts and authentication
- **Profile** - Extended user information
- **Room** - Room listings
- **RoomReview** - User reviews on rooms
- **UserDocument** - Document verification
- **ChatMessage** - Direct messages between users
- **Session** - JWT refresh token sessions

---

## 🧪 Testing

### Generate Test Data
```bash
# Seed database with 26 users, 30 rooms, 150 reviews, and more
docker exec -i roomy-mysql mysql -uroot -proot < backend/seed_loadtest_data.sql

# Verify seeding
docker exec roomy-mysql mysql -uroot -proot -D roomy1 -e \
  "SELECT COUNT(*) as users FROM user WHERE email LIKE 'loadtest_user%@roombridge.test';"
```

---

## 🎨 UI/UX Highlights

- **Responsive Design** - Works seamlessly on desktop, tablet, and mobile
- **Modern Dashboard** - Clean admin interface for content management
- **Real-time Chat** - Instant messaging without page refresh
- **Image Gallery** - Multi-image upload and carousel for room listings
- **Search & Filter** - Advanced filtering by location, price, and preference
- **User Reviews** - Community-driven ratings and feedback

---

## 🚦 Development Workflow

### Making Changes
1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and test
3. Commit: `git commit -m "feat: description"`
4. Push: `git push origin feature/your-feature`
5. Create Pull Request

### Running Tests
```bash
# Frontend tests
cd frontend
npm run test

# Backend tests  
cd backend
mvn test
```

---

## 📝 API Documentation

Complete API documentation available at:
- **Swagger UI**: `http://localhost:8081/swagger-ui.html` (if enabled)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👥 Authors

- **Akshat Jain** - Full Stack Development
- Project: Room Bridge - Connecting People & Spaces

---

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: akshatjme15@gmail.com

---

## 🎉 Acknowledgments

- Spring Boot & Spring Security documentation
- React & TypeScript communities
- Tailwind CSS framework
- MySQL & Redis
- All contributors and testers
