# erbswap

**Server-driven UI for Rails, without growing your own framework.**

🌐 **Live demo:** <https://erbswap.onrender.com>
(Free tier — first hit after idle may cold-start for ~30 seconds.)

A Rails controller concern and ~195 lines of dependency-free vanilla JavaScript.
Your server renders plain ERB partials. The browser does `fetch` + DOM swap.
That's the whole pattern.

```
fetch(form.action, { body }) → response.text() → target.outerHTML = html
```

No `npm`, no build step, no `hx-*` attributes, no `<turbo-frame>` custom element.
This is in the same family as [HTMX](https://htmx.org),
[Hotwire/Turbo](https://hotwired.dev), and
[Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) — all server-driven UI
approaches that keep your Rails view layer in charge instead of forcing a
JSON-API + SPA split.

The differentiator is **restraint**. erbswap deliberately stops at a small set
of capabilities and tells you to switch to HTMX, Turbo, or whatever you prefer
the moment your needs grow past them. The goal is to give you a starting point
that's smaller and cheaper than adopting a framework — not to *be* a framework.

---

# How to use

Two files. Two include lines. That's it.

### 1. Copy two files

| Path | What it is |
|---|---|
| `app/javascript/erbswap.js` | The library (under 200 lines, IIFE-wrapped, zero deps). |
| `app/controllers/concerns/erbswap_renderable.rb` | One private method. |

### 2. Wire them up

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include ErbswapRenderable
end
```

```ruby
# config/importmap.rb (if you're on Importmap)
pin "erbswap", to: "erbswap.js"
```

```javascript
// app/javascript/application.js
import "erbswap"
```

If you're on Sprockets:

```javascript
// app/assets/javascripts/application.js
//= require erbswap
```

Or just include it as a plain `<script>` tag — it's a self-executing IIFE that
registers `window.erbswap` and document listeners. It will work either way.

### 3. Write your first swap

A partial that's stable across every state:

```erb
<%# app/views/widgets/_widget_initial.html.erb %>
<div id="widget-frame">
  <form action="<%= submit_widget_path %>" method="post"
        data-erbswap-form="true"
        data-erbswap-target="widget-frame"
        data-erbswap-swap="replace">
    <%= hidden_field_tag :authenticity_token, form_authenticity_token %>
    <button type="submit" data-erbswap-loading-text="Processing…">Submit</button>
  </form>
</div>
```

```erb
<%# app/views/widgets/_widget_success.html.erb %>
<div id="widget-frame">
  <p>It worked.</p>
</div>
```

```ruby
def submit_widget
  render_erbswap(partial: "widgets/widget_success")
rescue StandardError => e
  render_erbswap(partial: "widgets/widget_error", locals: { message: e.message }, status: :unprocessable_entity)
end
```

### 4. Write down the invariants

Add a short section to your `CLAUDE.md`, `README`, or `ARCHITECTURE.md` listing
the [four invariants](#the-four-invariants). Without an explicit ceiling, you
will grow this into a 1,000-line internal framework. Make the ceiling visible
so contributors know where the wall is.

### 5. Add a system test per use case

```ruby
require "application_system_test_case"

class WidgetsTest < ApplicationSystemTestCase
  test "successful widget submit swaps the frame" do
    visit widgets_path
    click_button "Submit"
    assert_text "It worked"
  end
end
```

One per swap target. Look at `test/system/` in this repo for templates.

### What else to read

The five steps above get you to a working integration. For anything beyond
the first swap, these sections in the rest of this README are the reference:

- [**API reference**](#api-reference) — every data attribute, the `window.erbswap.load()` options, dispatched events, CSS hooks, CSRF behavior.
- [**The four invariants**](#the-four-invariants) — the load-bearing rules. Read these before you write your second swap.
- [**Anti-patterns**](#anti-patterns) — things to *not* do.
- [**Single-flight pattern**](#single-flight-pattern) — multi-form race prevention with CSS `:has()`.
- [**When to graduate**](#when-to-graduate) — signals that you've outgrown erbswap.

---

## Table of contents

- [Try it in 60 seconds in your local](#try-it-in-60-seconds-in-your-local)
- [The four invariants](#the-four-invariants)
- [The three examples in this repo](#the-three-examples-in-this-repo)
- [How it works](#how-it-works)
- [API reference](#api-reference)
- [Single-flight pattern](#single-flight-pattern)
- [When to graduate](#when-to-graduate)
- [Comparison with neighbors](#comparison-with-neighbors)
- [Anti-patterns](#anti-patterns)
- [FAQ](#faq)
- [License](#license)

---

## Try it in 60 seconds in your local

```bash
git clone https://github.com/erbswap/erbswap.git
cd erbswap
bundle install
bin/rails db:prepare
bin/rails server
```

Open <http://localhost:3000>. Three working demos. Each one is a few dozen lines
of plain ERB plus a server action that calls `render_erbswap(...)`.

Run the tests:

```bash
bin/rails test         # controllers (13 tests)
bin/rails test:system  # browser tests (10 tests)
```

---

## The four invariants

These are the load-bearing rules. The whole value of erbswap collapses if you
break them, because the library doesn't enforce them — *you* do.

1. **Same frame `id`, every state.** Every state's partial — `initial`,
   `success`, `empty`, `error` — wraps in the *same* `<div id="...">`. The next
   swap can always find its target no matter which state the page is in.

2. **Two swap modes only.** `innerHTML` (default) and `replace` (= `outerHTML`).
   No `beforeend`, `afterbegin`, no positional swap. If you find yourself
   wanting one, that's a signal to graduate to HTMX.

3. **Single controller entry point.** All erbswap responses go through one
   helper: `render_erbswap(partial:, locals:, status:)`. No second helper, no
   JSON envelope, no response wrapper. One method, one shape.

4. **Out of scope.** erbswap does not implement out-of-band swap, browser
   history (`pushState`/`popstate`), SSE / WebSocket streaming, request abort,
   retry, or debounce. The moment you need these, **stop extending erbswap and
   switch to a real library**. The whole point is that this is a starting line,
   not a destination.

The fourth invariant is the most important one. Without it, this codebase grows
to 1,000 lines and you've reinvented HTMX, worse.

---

## The three examples in this repo

| Path | Pattern | What it shows |
|---|---|---|
| `/examples/tasks` | Modal + form swap | A `<dialog>` opener triggers a fresh fetch (Pattern B). Each task-button is a form whose response swaps the frame inline (Pattern A). Demonstrates the same-id-across-every-state invariant and the [single-flight CSS pattern](#single-flight-pattern). |
| `/examples/signups/new` | Inline form validation | A username availability check using `method="get"` form semantics. No CSRF token needed. Demonstrates that a 422 response with a partial body is treated as a valid swap, not an error. |
| `/examples/articles` | Click-to-load | A list of articles with per-row "Show preview" buttons using `data-erbswap-action="load"`. Demonstrates many independent frames on one page. |

Each example page has a `<details>` block at the bottom called *What's
happening?* that walks through the request flow.

---

## How it works

### Server side

```ruby
# app/controllers/concerns/erbswap_renderable.rb
module ErbswapRenderable
  extend ActiveSupport::Concern

  private

  def render_erbswap(partial:, locals: {}, status: :ok)
    render partial: partial, locals: locals, formats: [:html], layout: false, status: status
  end
end
```

It's *one method*. It calls Rails' built-in `render` with `layout: false`. The
response is a plain HTML fragment.

```ruby
class TasksController < ApplicationController
  def run
    task_id = params[:task_id].to_i
    result  = lookup_result(task_id)

    if result.present?
      render_erbswap(partial: "tasks/modal_success", locals: { task_id:, item_count: result.size })
    else
      render_erbswap(partial: "tasks/modal_empty", locals: { task_id: })
    end
  rescue StandardError => e
    render_erbswap(
      partial: "tasks/modal_error",
      locals:  { task_id:, message: e.message },
      status:  :unprocessable_entity
    )
  end
end
```

### Client side

The JS library auto-binds two `document`-level listeners on load:

- **`submit`** on `form[data-erbswap-form="true"]` → preventDefault, fetch the
  form's `action` with its `FormData`, swap the response into the target.
- **`click`** on `[data-erbswap-action="load"]` → preventDefault, fetch the
  href / `data-erbswap-src`, swap the response into the target.

Because the listeners live on `document`, swapped-in HTML is automatically
"alive" — no re-binding step.

### A round trip

```
User clicks task button
   ↓
erbswap.js intercepts submit, sets loading state on button + form
   ↓
fetch(form.action, { method: POST, body: FormData })
   ↓
TasksController#run
   ↓
render_erbswap(partial: "tasks/modal_success", locals: { ... })
   ↓
Response body: <div id="task-frame">…success markup…</div>
   ↓
erbswap.js: target.outerHTML = html (swap mode "replace")
   ↓
The new HTML's inner forms are also picked up by the document listener
```

---

## API reference

### Data attributes

| Attribute | On | Purpose |
|---|---|---|
| `data-erbswap-form="true"` | `<form>` | Mark a form for erbswap to handle on submit. |
| `data-erbswap-target="frame-id"` | trigger | The `id` of the element to swap. |
| `data-erbswap-swap="innerHTML"` \| `"replace"` | trigger | Swap mode (default `innerHTML`). |
| `data-erbswap-src="/path"` | element or trigger | Fetch URL. On a target element it auto-loads on page mount. On a trigger it's the URL fetched on click. |
| `data-erbswap-action="load"` | clickable | Mark a button/link as a click-to-fetch trigger. |
| `data-erbswap-loading-text="…"` | `<button>` | Text shown on the submit button while the swap is in flight. |
| `data-erbswap-autoload="false"` | element with `src` | Skip the on-page-load auto-fetch. |
| `data-erbswap-error-html="…"` | target | Custom error HTML override (used on 5xx / network failure). |

### JavaScript API

```javascript
window.erbswap.load(url, targetIdOrElement, {
  method: "GET",                  // or POST/PATCH/DELETE
  body: null,                     // FormData / string / etc.
  headers: {},
  swap: "innerHTML",              // or "replace"
  errorHtml: "<div>…</div>",      // shown on 5xx / network failure
  onSuccess: ({ html, target, response }) => {},
  onError:   ({ error, target }) => {}
});

window.erbswap.scan(rootElement); // re-scan a subtree for auto-load targets
```

### Events

erbswap dispatches three `CustomEvent`s on `document`:

| Event | Detail | When |
|---|---|---|
| `erbswap:before-load` | `{ url, target }` | Just before the fetch starts. |
| `erbswap:after-load` | `{ url, target, html }` | After a successful swap. |
| `erbswap:error` | `{ url, target, error }` | On network failure or 5xx response. |

Use these for cross-cutting concerns like analytics, focus management, or flash
clearing. Do **not** use them for per-feature business logic — that belongs in
the server.

### CSS hooks

| Class | Applied to | When |
|---|---|---|
| `erbswap-loading` | target frame | While a fetch into it is in flight. |
| `erbswap-form-loading` | submitting form | While its swap is in flight. |
| `erbswap-submit-loading` | submit button | While its form's swap is in flight. |
| `erbswap-error` | target frame's `<div>` | When errorHtml is rendered (non-replace swap only). |

The target also gets `aria-busy="true"` while loading.

### CSRF

erbswap reads `<meta name="csrf-token" content="…">` from your layout and sends
it as `X-CSRF-Token` on `POST`/`PATCH`/`DELETE`/`PUT`. Rails' built-in
`<%= csrf_meta_tags %>` provides it. Form-submitted swaps also include the
`authenticity_token` hidden input via `FormData`.

---

## Single-flight pattern

When you have multiple sibling forms (e.g. four task-buttons), a user clicking
two in rapid succession would fire two overlapping requests. The first response
to arrive wins, the second clobbers it. Bad.

erbswap solves this with **zero JavaScript** using CSS `:has()`:

```css
.task-frame__actions:has(form.erbswap-form-loading) form:not(.erbswap-form-loading) {
  display: none;
}
```

When one form in the container is loading (has `erbswap-form-loading`), all
sibling forms are hidden. The user simply can't click them.

Once the response arrives and `outerHTML`-replaces the container, every form in
it is gone anyway — no class to clear, nothing to reset.

Browser support: `:has()` works in Chrome 105+, Firefox 121+, Safari 15.4+.

---

## When to graduate

If you hit any of these, **stop extending erbswap** and pick the appropriate
tool. The whole library exists to make this transition cheap, not to fight it.

| Signal | Pick |
|---|---|
| One response should update several frames at once | HTMX with `hx-swap-oob` |
| Browser back/forward, URL-shareable state | Turbo Drive, or HTMX `hx-push-url` |
| WebSocket / SSE driven UI updates | Turbo Streams or HTMX SSE extension |
| Optimistic UI / client-side state | Alpine.js (small) or React (large) |
| 5+ frames depending on each other | HTMX or React |
| Live search / keystroke-triggered fetches with debounce | HTMX `hx-trigger="keyup changed delay:300ms"` |

If none of these apply: the under-200-line file is the most boring, lowest-risk
option. Use it.

---

## Comparison with neighbors

| Pattern | Differentiator |
|---|---|
| **HTMX** | Full framework. 25+ `hx-*` attributes, everything in our [out-of-scope list](#the-four-invariants). Most extensible; biggest learning surface. |
| **Hotwire / Turbo** | Rails 7+ default. Magic via `<turbo-frame>` and `<turbo-stream>`. Requires buying into the Hotwire ecosystem. |
| **Phoenix LiveView** | Elixir-only. Stateful WebSocket-driven UI. The closest in spirit but in a different language. |
| **Unpoly** | Rails-friendly hypermedia framework with layers, fragments, and a richer API surface. |
| **erbswap** | The smallest possible thing that does form swaps and click swaps. Form-first, no DSL, zero deps, [explicit ceiling](#the-four-invariants). |

See [`docs/COMPARISONS.md`](docs/COMPARISONS.md) for a fuller table.

---

## Anti-patterns

Things to *not* do, in increasing order of damage:

- **Partial without a frame wrapper.** Always `<div id="…">`. Without it the
  next swap has no target.
- **Different `id` per state.** Initial state uses `task-frame`, success uses
  `task-result`. The next swap fails because the new target isn't reachable.
  All four states must use the *same* id.
- **Domain logic in `erbswap.js`.** The library is transport only. Business
  logic belongs in your controllers and services.
- **`<script>` blocks inside swapped partials.** When the partial re-swaps the
  script runs again, leaking state. Use the `erbswap:after-load` event from a
  global location instead.
- **Building out-of-band swap, retry, history.** That's [invariant #4](#the-four-invariants).
  When you need any of these, that's your signal to switch.

---

## FAQ

**Why not just use Hotwire?**
You should, if Hotwire's tradeoffs work for you. erbswap exists for cases where
you want async swaps in a small slice of your app and adopting Hotwire feels
disproportionate. It's a starting point with a clear upgrade path.

**Why not just use HTMX?**
Same answer. If HTMX's tradeoffs work for you, use HTMX. erbswap exists for
the smaller end of the spectrum where 25+ `hx-*` attributes is more than you
want to learn for one form swap.

**What happens on a 422 response?**
The body is swapped in. The library treats 4xx as "the server intentionally
returned this state with a partial body" rather than as an error. Only 5xx and
network failures trigger the error path.

**What happens when the form is re-rendered by a swap — do the listeners stop working?**
No. Listeners live on `document`, not on individual elements. New HTML inside
swapped frames is "alive" automatically.

**Does it work without Turbo / Hotwire?**
Yes. This repo's demo runs with `--skip-hotwire`. Turbo is fully optional. If
Turbo is present, erbswap also re-scans on `turbo:load` / `turbo:render`.

**Does it work with Sprockets, Propshaft, and Importmap?**
Yes. The file is a self-contained IIFE — load it however your asset pipeline
prefers, including via a plain `<script>` tag.

**Is it accessible?**
Loading frames get `aria-busy="true"`. Submit buttons get `disabled` and
`aria-disabled` flipped during the swap. Focus is *not* restored after a
swap — if your swap target contains a form the user was inside, focus is lost
along with the old DOM. This is a known limitation; see invariant #4 and pick a
real library if you need it.

---

## License

MIT. See [LICENSE](LICENSE).

## Credits

Built by Jinsun Lim.

PRs and forks welcome. The one PR the maintainer will reject without comment is
"please add feature X" where X is on the [out-of-scope list](#the-four-invariants).
