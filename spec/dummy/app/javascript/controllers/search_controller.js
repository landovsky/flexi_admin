import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "results", "form"]
  static values = {
    url: String,
    debounce: { type: Number, default: 300 }
  }

  connect() {
    console.log("Search controller connected")
    this.debouncedSearch = this.debounce(this.search.bind(this), this.debounceValue)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  // Handle input changes
  input(event) {
    this.debouncedSearch(event)
  }

  // Perform the search
  search(event) {
    const query = this.inputTarget.value.trim()

    // Skip if query is too short
    if (query.length === 0 || query.length === 1) {
      return
    }

    // Build URL with search params
    const url = new URL(this.urlValue || window.location.href)
    url.searchParams.set('q', query)
    url.searchParams.delete('page') // Reset to page 1 on search

    // Fetch results via Turbo
    this.fetchResults(url.toString())
  }

  // Submit the search form
  submit(event) {
    event.preventDefault()

    const query = this.inputTarget.value.trim()
    const url = new URL(this.urlValue || window.location.href)
    url.searchParams.set('q', query)
    url.searchParams.delete('page') // Reset to page 1 on search

    this.fetchResults(url.toString())
  }

  // Clear search
  clear(event) {
    event.preventDefault()
    this.inputTarget.value = ''

    const url = new URL(this.urlValue || window.location.href)
    url.searchParams.delete('q')

    this.fetchResults(url.toString())
  }

  // Fetch results using Turbo Stream
  fetchResults(url) {
    fetch(url, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html, text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => {
      if (response.headers.get('Content-Type')?.includes('turbo-stream')) {
        return response.text()
      } else {
        // Fallback: navigate to the URL
        Turbo.visit(url)
        return null
      }
    })
    .then(html => {
      if (html) {
        Turbo.renderStreamMessage(html)
      }
    })
    .catch(error => {
      console.error('Search error:', error)
    })
  }

  // Debounce utility
  debounce(func, wait) {
    return (...args) => {
      if (this.timeout) {
        clearTimeout(this.timeout)
      }
      this.timeout = setTimeout(() => {
        func(...args)
      }, wait)
    }
  }
}
