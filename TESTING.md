# Manual Testing Guide for Todo Today

This guide helps you manually test all the features of the Todo Today application since we can't run automated Ruby commands in this environment.

## Prerequisites

Before testing, make sure you have:
1. Run `bundle install` to install dependencies
2. Run `./bin/rails db:create` to create the database
3. Run `./bin/rails db:migrate` to set up the database schema
4. Optionally run `./bin/rails db:seed` to add sample data

## Starting the Application

```bash
./bin/rails server
```

Then visit `http://localhost:3000` in your browser.

## Test Scenarios

### 1. Basic Navigation Test
**Goal**: Verify the application loads and navigation works

**Steps**:
1. Visit `http://localhost:3000`
2. Check that you see the "Todo Today" header
3. Verify you see navigation links for "Tasks" and "Reports"
4. Click "Reports" - should navigate to reports page
5. Click "Tasks" - should return to tasks page

**Expected Results**:
- Clean, modern interface loads
- Navigation works without errors
- Responsive design on different screen sizes

### 2. Task Creation Test
**Goal**: Verify you can create new tasks

**Steps**:
1. On the main tasks page, click "Add New Task"
2. Enter a task name: "Drink 8 glasses of water"
3. Click "Create Task"
4. Verify you're redirected back to tasks list
5. Confirm the new task appears in the list

**Expected Results**:
- Form loads properly
- Task is created and appears in list
- Success message is displayed

### 3. Task Completion Test
**Goal**: Test the core completion functionality

**Steps**:
1. Find a task in the list (create one if needed)
2. Click the circle (○) button next to the task
3. Verify the button changes to a checkmark (✓)
4. Verify the task item gets a "completed" visual style
5. Click the checkmark (✓) to uncomplete
6. Verify it changes back to circle (○)

**Expected Results**:
- Page doesn't reload (Turbo Streams working)
- Visual feedback is immediate
- Task completion state persists on page refresh

### 4. Task Management Test
**Goal**: Test CRUD operations

**Steps**:
1. Create a task: "Test Task for Editing"
2. Click "Edit" next to the task
3. Change the name to "Updated Test Task"
4. Click "Update Task"
5. Verify the name changed in the list
6. Click "Delete" next to the task
7. Confirm the deletion
8. Verify the task is removed from the list

**Expected Results**:
- Edit form pre-populates with current name
- Updates save properly
- Deletion works with confirmation
- All operations show appropriate success messages

### 5. Completion Rate Display Test
**Goal**: Verify completion rates are calculated and displayed

**Steps**:
1. Complete several tasks (if you have sample data)
2. Look at the completion percentage shown next to each task
3. Complete a task and refresh the page
4. Verify the completion rate updates

**Expected Results**:
- Completion rates show as percentages (e.g., "67.7% (30 days)")
- Rates update when tasks are completed
- New tasks show 0% or low percentages

### 6. Reports Functionality Test
**Goal**: Test the reporting features

**Steps**:
1. Navigate to "Reports" page
2. Try different time period buttons (7 Days, 30 Days, 90 Days)
3. Look for completion rate percentages
4. Check the visual calendar (dots/squares showing completed days)
5. Review the summary table at the bottom

**Expected Results**:
- Different time periods load different data
- Completion rates are displayed prominently
- Visual calendar shows completion patterns
- Summary table shows statistics

### 7. Responsive Design Test
**Goal**: Verify the app works on different screen sizes

**Steps**:
1. Test on desktop browser (full width)
2. Resize browser window to tablet size (~768px)
3. Resize to mobile size (~375px)
4. Test all functionality at each size

**Expected Results**:
- Layout adapts to screen size
- Navigation remains usable
- Task completion buttons remain clickable
- Text remains readable

### 8. Daily Reset Logic Test
**Goal**: Verify tasks reset daily (requires time manipulation or patience)

**Steps**:
1. Complete several tasks
2. Note which tasks are marked complete
3. Wait until the next day OR temporarily modify the date logic
4. Refresh the page
5. Verify all tasks show as incomplete again

**Expected Results**:
- Completed tasks show as incomplete the next day
- Historical completion data is preserved (visible in reports)
- New day allows tasks to be completed again

### 9. Error Handling Test
**Goal**: Test error conditions

**Steps**:
1. Try to create a task with an empty name
2. Try to visit a non-existent URL like `/tasks/99999`
3. Try to edit a task and remove the name

**Expected Results**:
- Form validation prevents empty task names
- 404 page displays for invalid URLs
- Error messages are user-friendly

### 10. Data Persistence Test
**Goal**: Verify data persists across sessions

**Steps**:
1. Create several tasks
2. Complete some of them
3. Close the browser completely
4. Reopen and visit the app
5. Verify all tasks and completion states are preserved

**Expected Results**:
- All tasks remain after browser restart
- Completion history is maintained
- Reports show historical data

## Performance Checks

### Visual Performance
- Pages load quickly
- No layout shifts during loading
- Smooth animations for task completion
- Responsive interactions (no lag)

### JavaScript Console
1. Open browser developer tools (F12)
2. Check Console tab for any JavaScript errors
3. Navigate through the app and complete tasks
4. Verify no errors appear during normal usage

## Common Issues and Solutions

### Tasks Not Updating
- Check browser console for JavaScript errors
- Verify Turbo is loaded (should see turbo.js in Network tab)
- Try hard refresh (Ctrl+F5 or Cmd+Shift+R)

### Styling Issues
- Verify application.scss is being loaded
- Check for CSS compilation errors in Rails logs
- Test in different browsers (Chrome, Firefox, Safari)

### Database Issues
- If tasks aren't persisting, check database connection
- Verify migrations have run successfully
- Check Rails server logs for database errors

## Success Criteria

The app passes testing if:
- ✅ All navigation works without errors
- ✅ Tasks can be created, edited, and deleted
- ✅ Task completion works with real-time updates
- ✅ Reports show accurate completion data
- ✅ Interface is responsive and user-friendly
- ✅ Data persists across browser sessions
- ✅ No JavaScript errors in console
- ✅ Daily reset concept works (tasks can be re-completed each day)

## Reporting Issues

If you find any issues during testing:
1. Note the specific steps that caused the problem
2. Check browser console for error messages
3. Check Rails server logs for server-side errors
4. Document the expected vs actual behavior
5. Test in multiple browsers if possible

Happy testing! 🚀