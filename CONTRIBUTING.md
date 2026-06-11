# Contributing to erbswap

Thanks for considering a contribution. A short note on what kinds of changes
land easily, and what kinds don't.

## What lands easily

- **Bug fixes** in `app/javascript/erbswap.js` or
  `app/controllers/concerns/erbswap_renderable.rb`.
- **Documentation improvements** — clearer wording, better examples, fixing
  typos.
- **Test coverage** — additional system or controller tests for edge cases.
- **Demo improvements** — clearer CSS, more accessible markup, additional
  example pages that demonstrate an existing capability in a new context.
- **Asset-pipeline notes** — Sprockets / Propshaft / Importmap interop
  improvements in the README or the library.

## What doesn't land

Anything that grows the scope past the
[four invariants](docs/INVARIANTS.md). Specifically:

- Out-of-band swap (one response updating multiple frames).
- Browser history (`pushState` / `popstate`).
- SSE / WebSocket / streaming responses.
- Request abort, retry, debounce, throttle, polling.
- A second response helper alongside `render_erbswap`.
- Additional swap modes beyond `innerHTML` and `replace`.

These features are exactly what HTMX, Turbo, Unpoly, and Phoenix LiveView do
well. The whole point of erbswap is that it *doesn't* try to compete with them.
If a use case in your app needs any of the above, the right move is to migrate
that surface to a real library, not to extend erbswap.

A PR that adds one of these will be closed with a link to this section.

## How to develop

```bash
git clone <your fork>
cd erbswap
bundle install
bin/rails db:prepare
bin/rails server
```

Run the test suite:

```bash
bin/rails test         # controller + integration tests
bin/rails test:system  # browser-driven system tests (headless Chrome)
```

System tests require a recent Chrome on the machine. They drive a headless
browser via Selenium.

## Style

The Ruby side follows
[`rubocop-rails-omakase`](https://github.com/rails/rubocop-rails-omakase),
which is what `rails new` ships. The JS side has no formatter — keep it
readable and consistent with the existing file.

## Code of conduct

Be kind. We're all here to keep our Rails apps small and our async swaps
boring.
