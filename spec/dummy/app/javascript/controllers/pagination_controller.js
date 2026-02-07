import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pagination"
export default class extends Controller {
  static targets = ["pageLink", "perPageSelect", "content"]
  static values = {
    url: String,
    currentPage: { type: Number, default: 1 },
    perPage: { type: Number, default: 12 },
    totalPages: Number
  }

  connect() {
    console.log("Pagination controller connected", {
      currentPage: this.currentPageValue,
      perPage: this.perPageValue,
      totalPages: this.totalPagesValue
    })
  }

  // Change page number
  changePage(event) {
    event.preventDefault()

    const link = event.currentTarget
    const page = link.dataset.page || this.extractPageFromURL(link.href)

    if (!page || page === this.currentPageValue.toString()) {
      return
    }

    this.loadPage(page)
  }

  // Go to next page
  nextPage(event) {
    event.preventDefault()

    if (this.hasNextPage()) {
      this.loadPage(this.currentPageValue + 1)
    }
  }

  // Go to previous page
  previousPage(event) {
    event.preventDefault()

    if (this.hasPreviousPage()) {
      this.loadPage(this.currentPageValue - 1)
    }
  }

  // Go to first page
  firstPage(event) {
    event.preventDefault()
    this.loadPage(1)
  }

  // Go to last page
  lastPage(event) {
    event.preventDefault()

    if (this.totalPagesValue) {
      this.loadPage(this.totalPagesValue)
    }
  }

  // Change items per page
  changePerPage(event) {
    const perPage = event.target.value

    if (!perPage || perPage === this.perPageValue.toString()) {
      return
    }

    // Update URL with new per_page value and reset to page 1
    const url = new URL(this.urlValue || window.location.href)
    url.searchParams.set('per_page', perPage)
    url.searchParams.delete('page') // Reset to page 1

    this.fetchPage(url.toString())
  }

  // Load a specific page
  loadPage(page) {
    const url = new URL(this.urlValue || window.location.href)
    url.searchParams.set('page', page)

    this.fetchPage(url.toString())
  }

  // Fetch page using Turbo Stream
  fetchPage(url) {
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
      console.error('Pagination error:', error)
    })
  }

  // Extract page number from URL
  extractPageFromURL(url) {
    try {
      const urlObj = new URL(url)
      return urlObj.searchParams.get('page')
    } catch (error) {
      return null
    }
  }

  // Check if there's a next page
  hasNextPage() {
    return !this.totalPagesValue || this.currentPageValue < this.totalPagesValue
  }

  // Check if there's a previous page
  hasPreviousPage() {
    return this.currentPageValue > 1
  }
}
