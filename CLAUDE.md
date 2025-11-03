# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Rails 7.0 daily task manager application with habit tracking and reporting capabilities. Tasks repeat every day and are automatically reset at the end of each day. The application logs task completions and provides completion rate reports.

### Core Features
- **Daily Repeating Tasks**: Tasks automatically recur each day
- **Task Completion Tracking**: Log when tasks are completed throughout the day
- **Daily Reset**: All tasks reset at end of day (completed status cleared)
- **Completion Rate Reports**: View historical completion rates for tasks
- **Task Management**: Full CRUD operations (create, read, update, delete) for tasks

## Technology Stack

- **Framework**: Rails 7.0.0 with Ruby 3.1.3
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo Rails + Stimulus), jQuery, Importmap
- **Styling**: SASS (via sassc-rails)
- **Server**: Puma
- **Testing**: Capybara with Selenium WebDriver

## Development Commands

### Setup
```bash
bundle install                    # Install dependencies
rails db:create                   # Create database
rails db:migrate                  # Run migrations
rails db:seed                     # Seed database (if seeds exist)
```

### Running the Application
```bash
rails server                      # Start server on http://localhost:3000
rails s                           # Short form
```

### Database
```bash
rails db:migrate                  # Run pending migrations
rails db:rollback                 # Rollback last migration
rails db:migrate:status           # Check migration status
rails db:reset                    # Drop, create, and migrate database
```

### Testing
```bash
rails test                        # Run all tests
rails test:system                 # Run system tests
rails test TEST=test/path/file.rb # Run specific test file
```

### Console and Debugging
```bash
rails console                     # Start Rails console
rails c                           # Short form
rails dbconsole                   # Database console
```

### Code Generation
```bash
rails generate model ModelName    # Generate model
rails generate controller Name    # Generate controller
rails generate migration Name     # Generate migration
```

## Architecture Notes

### Data Model
The application centers around two key models:

- **Task**: Represents a repeating daily task
  - Name/description of the task
  - Any task-specific settings

- **TaskCompletion**: Logs each time a task is completed
  - Links to a Task
  - Timestamp of completion
  - Date of completion (for reporting)

This separation allows tasks to persist while completions are logged historically, enabling completion rate calculations over time.

### Daily Reset Mechanism
Tasks need to be reset daily (completion status cleared). Consider implementing this with:
- A scheduled job (using cron or Rails whenever gem) that runs at end of day
- A before_filter that checks if a new day has started since last visit
- A background job scheduler (sidekiq, delayed_job) for production

### Completion Rate Reporting
Reports should aggregate TaskCompletion records grouped by date and task. Calculate rates by comparing completed tasks against total tasks for each day. Consider different reporting timeframes:
- Daily view (today's completion status)
- Weekly summary (completion rates for past 7 days)
- Monthly trends (completion patterns over time)

### Frontend Architecture
The application uses Hotwire for a modern SPA-like experience:
- **Turbo**: Handle real-time updates when marking tasks complete without page reloads
- **Stimulus**: Add interactive behavior for task completion toggles, inline editing
- Use Turbo Frames for the task list to update dynamically
- Use Turbo Streams for real-time updates when completing tasks

### Asset Pipeline
Uses importmap-rails for JavaScript dependencies rather than a Node.js bundler. Import JavaScript modules directly in the browser using ES6 imports.

## Project State

This repository is currently in a skeleton state with only the Gemfile configured. The following need to be implemented:
- Models (Task, TaskCompletion)
- Controllers (TasksController, ReportsController/TaskCompletionsController)
- Routes for CRUD operations and reporting
- Views with Turbo/Stimulus integration for real-time task completion
- Database migrations for tasks and task_completions tables
- Daily reset mechanism (scheduled job or check on request)
- Completion rate report views and queries
- Configuration files (routes.rb, database.yml, etc.)
