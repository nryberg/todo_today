# Todo Today - Rails Daily Task Manager

## 📋 Project Overview

A Rails 7.0 daily task manager application with habit tracking and reporting capabilities. Tasks automatically repeat every day and are reset at the end of each day. The application tracks task completions and provides visual completion rate reports to help build better habits.

## 🎯 Core Features

- **Daily Repeating Tasks**: Tasks automatically recur each day with automatic reset
- **Real-time Task Completion**: Mark tasks complete/incomplete instantly with Turbo Streams
- **Smart Task Sorting**: Completed tasks automatically move to the bottom of the list
- **Visual Completion Reports**: Calendar-style completion tracking with 7-day grid layout
- **Completion Analytics**: Track completion rates over 7, 30, or 90-day periods
- **Multi-User Authentication**: Devise-based auth with optional Google OAuth (feature flagged)
- **Responsive Design**: Modern CSS with gradients, animations, and mobile support
- **Data Persistence**: SQLite database with volume mounts for data survival across rebuilds

## 🏗️ Technical Architecture

### **Backend Stack**
- **Framework**: Rails 7.0.0 with Ruby 3.1.3
- **Database**: SQLite3 (production-ready for single-user/home server)
- **Authentication**: Devise with custom controllers
- **Authorization**: User-scoped data isolation

### **Frontend Stack**
- **Real-time Updates**: Hotwire (Turbo Streams + Stimulus)
- **JavaScript**: Importmap-based ES6 modules
- **Styling**: Custom SCSS with modern CSS Grid and Flexbox
- **UI/UX**: Professional gradients, smooth animations, responsive design

### **Data Model**
- **Task**: Persistent daily tasks (`name`, `user_id`, timestamps)
- **TaskCompletion**: Historical completion log (`task_id`, `completed_at`, timestamps)
- **User**: Authentication and user isolation (`email`, `name`, `provider`, `uid`)
- **Daily Reset Logic**: Completion status determined by existence of today's TaskCompletion record

### **Key Design Patterns**
- **Separation of Concerns**: Tasks (persistent) vs TaskCompletions (historical)
- **Feature Flags**: Google OAuth toggleable via `ENABLE_GOOGLE_OAUTH` env var
- **Smart Sorting**: Ruby-based task reordering (incomplete first, then completed)
- **User Scoping**: All queries scoped to `current_user` for multi-tenant isolation

## 🚀 Deployment Configuration

### **Docker Setup**
- **Primary Container**: Rails app on port 3000
- **Optional Proxy**: Nginx reverse proxy on port 8080 (disabled by default)
- **Data Persistence**: Volume mounts for database, logs, storage, and temp files
- **Health Checks**: Container health monitoring for reliable deployments

### **Environment Configuration**
```bash
# Core Settings
RAILS_ENV=production
SECRET_KEY_BASE=<generated-64-char-hex>
APP_HOST=bigbox
APP_PORT=3000

# Feature Flags
ENABLE_GOOGLE_OAUTH=false

# Docker Settings
DOCKERFILE=Dockerfile.debug
SEED_DB=true
```

### **Persistent Data Structure**
```
todo_today/
├── db/production.sqlite3     # Database (persisted)
├── log/production.log        # Application logs (persisted)
├── storage/                  # File uploads (persisted)
├── tmp/                      # PIDs and cache (persisted)
├── backups/                  # Automated backup snapshots
└── [Docker configs]
```

## 🛠️ Development Tools Created

### **Deployment Scripts**
- `docker-build.sh` - Comprehensive deployment automation with diagnostics
- `setup-data-dirs.sh` - Data persistence directory initialization
- `backup-data.sh` - Automated backup creation with timestamps
- `restore-data.sh` - Backup restoration with safety checks
- `debug.sh` - System diagnostic and troubleshooting tool
- `show-oauth-urls.sh` - Google OAuth configuration helper

### **Docker Configuration**
- `Dockerfile` - Standard Rails production container
- `Dockerfile.simple` - Cross-platform build compatibility
- `Dockerfile.minimal` - Lightweight deployment option
- `Dockerfile.debug` - Enhanced logging and error handling
- `docker-compose.yml` - Multi-service orchestration
- `nginx/` - Reverse proxy configuration (optional)

## 🎨 User Interface Highlights

### **Authentication Pages**
- Modern gradient backgrounds with glassmorphism cards
- Unified design between sign-in and sign-up pages
- Google OAuth integration with proper branding
- Responsive mobile-first design
- Professional error message styling

### **Main Application**
- Clean navigation with dropdown user menu
- Real-time task completion without page reloads
- Visual feedback with smooth animations
- Professional task cards with completion percentages
- Smart visual separation of completed/incomplete tasks

### **Reports Dashboard**
- Traditional 7-day calendar grid layout
- Color-coded completion visualization (green = completed)
- Multiple time period views (7/30/90 days)
- Completion rate statistics
- Summary tables with detailed analytics

## 📊 Current State

### **Fully Implemented**
- ✅ Complete CRUD operations for tasks
- ✅ Real-time task completion with Turbo Streams
- ✅ Multi-user authentication with user isolation
- ✅ Visual completion reports with calendar grid
- ✅ Docker deployment with data persistence
- ✅ Google OAuth integration (feature flagged)
- ✅ Responsive design for all screen sizes
- ✅ Comprehensive deployment automation
- ✅ Backup and restore functionality

### **Architecture Strengths**
- **Scalable**: User-scoped data model supports multiple users
- **Maintainable**: Clean separation of concerns with Rails conventions
- **Deployable**: Production-ready Docker configuration
- **Persistent**: Data survives container rebuilds and updates
- **Flexible**: Feature flags and environment-based configuration
- **Professional**: Modern UI/UX with smooth interactions

### **Production Ready For**
- Single user or small team deployments
- Home server installations
- Development and staging environments
- Docker-based cloud deployments

### **Access Information**
- **Main Application**: `http://bigbox:3000`
- **Google OAuth Callback**: `http://bigbox:3000/users/auth/google_oauth2/callback`
- **Health Check**: `http://bigbox:3000/health`

## 🎯 Next Steps Opportunities

- **SSL/HTTPS**: Let's Encrypt integration for production domains
- **Advanced Analytics**: Streak tracking, habit insights, goal setting
- **Data Export**: CSV/JSON export functionality
- **Task Categories**: Organization and filtering capabilities
- **Mobile App**: React Native or PWA implementation
- **Team Features**: Shared tasks, team analytics, collaboration
- **Integrations**: Calendar sync, notification systems, webhook APIs

## 🚀 Quick Start Commands

### **Initial Deployment**
```bash
# Clone and deploy
git clone https://github.com/nryberg/todo_today.git
cd todo_today
./docker-build.sh
```

### **Daily Operations**
```bash
# Start/stop application
docker compose up -d        # Start
docker compose down         # Stop
docker compose restart      # Restart

# Data management
./backup-data.sh           # Create backup
./restore-data.sh <backup> # Restore backup

# Diagnostics
./debug.sh                 # System diagnostics
docker compose logs -f web # View live logs
```

### **Configuration**
```bash
# Enable Google OAuth
echo "ENABLE_GOOGLE_OAUTH=true" >> .env
echo "GOOGLE_CLIENT_ID=your_id" >> .env
echo "GOOGLE_CLIENT_SECRET=your_secret" >> .env
docker compose restart

# Update application
git pull
docker compose up -d --build
```

---

This represents a fully functional, production-ready daily task manager with modern Rails architecture, comprehensive deployment automation, and professional user experience design.

**Created**: November 2024  
**Status**: Production Ready  
**GitHub**: https://github.com/nryberg/todo_today