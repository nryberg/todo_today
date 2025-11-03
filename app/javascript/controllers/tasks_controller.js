import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="task"
export default class extends Controller {
  static targets = ["checkbox", "item"]
  static values = {
    taskId: Number,
    completed: Boolean
  }

  connect() {
    this.updateItemState()
  }

  completedValueChanged() {
    this.updateItemState()
  }

  toggle(event) {
    event.preventDefault()

    const checkbox = event.currentTarget
    const isCompleted = checkbox.classList.contains('checked')

    // Add loading state
    checkbox.disabled = true
    checkbox.style.opacity = '0.6'

    // Submit the form
    const form = checkbox.closest('form')
    if (form) {
      form.requestSubmit()
    }
  }

  updateItemState() {
    if (this.hasItemTarget) {
      if (this.completedValue) {
        this.itemTarget.classList.add('completed')
      } else {
        this.itemTarget.classList.remove('completed')
      }
    }
  }

  // Called when turbo stream updates complete
  taskUpdated() {
    // Re-enable checkbox after update
    if (this.hasCheckboxTarget) {
      this.checkboxTarget.disabled = false
      this.checkboxTarget.style.opacity = '1'
    }
  }

  // Add subtle animation on completion
  celebrate() {
    if (this.hasItemTarget) {
      this.itemTarget.style.transform = 'scale(1.02)'
      setTimeout(() => {
        this.itemTarget.style.transform = 'scale(1)'
      }, 200)
    }
  }
}
