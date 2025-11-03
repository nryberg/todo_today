# Todo Today 📋

A Rails 7.0 daily task manager application with habit tracking and reporting capabilities. Tasks automatically repeat every day and reset at the end of each day. Track your daily habits with visual completion calendars and detailed analytics.

![Rails](https://img.shields.io/badge/rails-%23CC0000.svg?style=for-the-badge&logo=ruby-on-rails&logoColor=white)
![Ruby](https://img.shields.io/badge/ruby-%23CC342D.svg?style=for-the-badge&logo=ruby&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

## ✨ Features

- **📅 Daily Repeating Tasks**: Tasks automatically recur each day with automatic reset
- **⚡ Real-time Updates**: Mark tasks complete/incomplete instantly with Turbo Streams
- **📊 Completion Analytics**: Visual completion calendars and percentage tracking
- **🔄 Smart Sorting**: Completed tasks automatically move to the bottom
- **📱 Responsive Design**: Works perfectly on desktop and mobile
- **🎯 Habit Tracking**: Track completion rates over 7, 30, or 90-day periods
- **🚀 Modern Rails**: Built with Rails 7, Hotwire, and Stimulus

## 🚀 Quick Start

### Prerequisites

- Ruby 3.1.3
- Rails 7.0+
- SQLite3

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/nryberg/todo_today.git
   cd todo_today
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   ./bin/rails db:create
   ./bin/rails db:migrate
   ./bin/rails db:seed    # Optional: adds sample tasks
   ```

4. **Start the server**
   ```bash
   ./bin/rails server
   ```

5. **Open the app**
   Visit `http://localhost:3000`

## 📖 Usage

### Managing Tasks
- **Create**: Click "Add New Task" and enter a task name
- **Complete**: Click the circle (○) to mark complete, checkmark (✓) to mark incomplete
- **Edit/Delete**: Use the action buttons on each task
- **Reset All**: Use "Reset All Tasks" to mark everything as undone

### Viewing Reports
- Click "Reports" to see completion analytics
- Choose time periods: 7, 30, or 90 days
- View completion rates and calendar patterns
- Green squares = completed days, gray = missed days

## 🏗️ Architecture

### Data Model
- **Task**: Persistent daily tasks with names and metadata
- **TaskCompletion**: Historical log of when tasks were completed
- **Daily Reset Logic**: Tasks can be re-completed each day automatically

### Tech Stack
- **Backend**: Rails 7.0, Ruby 3.1.3, SQLite3
- **Frontend**: Hotwire (Turbo + Stimulus), SCSS, Responsive CSS
- **Features**: Real-time updates, mobile-first design, modern UX

### Key Features
- **No page reloads**: Turbo Streams provide instant feedback
- **Smart sorting**: Incomplete tasks stay at top, completed move to bottom  
- **Calendar visualization**: Traditional 7-day calendar grid for reports
- **Completion analytics**: Track habit consistency over time

## 🛠️ Development

### Database Commands
```bash
./bin/rails db:migrate          # Run migrations
./bin/rails db:rollback         # Rollback last migration  
./bin/rails db:reset           # Reset database
./bin/rails db:seed            # Add sample data
```

### Testing
```bash
./bin/rails test               # Run tests
./bin/rails console            # Rails console
```

### Asset Pipeline
Uses Rails 7 importmap for JavaScript modules and SCSS for styling.

## 📱 Screenshots

### Daily Tasks View
- Clean, modern interface with completion checkboxes
- Real-time updates without page refresh
- Smart sorting with completed tasks at bottom

### Completion Reports  
- Traditional calendar grid (7 days per week)
- Visual completion patterns over time
- Detailed analytics and completion percentages

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🎯 Use Cases

Perfect for:
- **Daily habit tracking** (exercise, reading, water intake)
- **Routine management** (morning routines, work tasks)
- **Health goals** (medication, vitamins, self-care)
- **Productivity tracking** (writing, learning, practice)

## 🔮 Future Features

- [ ] Task categories and tags
- [ ] Streak tracking and achievements
- [ ] Data export (CSV, JSON)
- [ ] Multiple user support
- [ ] Task scheduling (specific times)
- [ ] Mobile app (React Native)

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/nryberg/todo_today/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/nryberg/todo_today/discussions)
- 📧 **Contact**: Create an issue for questions

---

**Start building better habits today!** ⭐ Star this repo if you find it useful!