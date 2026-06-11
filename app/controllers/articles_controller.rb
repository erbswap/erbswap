class ArticlesController < ApplicationController
  ARTICLES = [
    {
      id: 1,
      title: "Server-driven UI is good, actually",
      snippet: "Why hypermedia is more productive than JSON+SPA for most apps.",
      body: "The original Rails value proposition was that the server is the single source of truth for both data and presentation. JSON+SPA splits this into two services that have to be kept in sync, and that sync is where most bugs and most engineering time go. Hypermedia keeps the server in charge."
    },
    {
      id: 2,
      title: "Don't build a framework",
      snippet: "The NIH trap and how to set a ceiling on your own libraries.",
      body: "Every internal abstraction that grows past 500 lines starts to look like a competitor to something on GitHub. Once you have request abort, retry, debounce, history, and out-of-band updates, you have rewritten HTMX, badly. Set a ceiling. Write it down. Hold to it."
    },
    {
      id: 3,
      title: "ERB partials are underrated",
      snippet: "Why your existing Rails view layer is already enough.",
      body: "Rails partials handle local variables, default arguments, collections, layouts, and conditional rendering with no extra plumbing. The same partial you render server-side can be the response body of a fetch. No transform, no serializer, no envelope. Just HTML in, HTML out."
    }
  ].freeze

  def index
    @articles = ARTICLES
  end

  def preview
    article = ARTICLES.find { |a| a[:id] == params[:id].to_i }

    if article
      render_erbswap(
        partial: "articles/article_preview",
        locals: { article: article }
      )
    else
      head :not_found
    end
  end
end
