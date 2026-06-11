# Comparison with neighbors

erbswap belongs to the **server-driven UI** / **hypermedia** family. That family
keeps your server's view layer in charge — the page is HTML in, HTML out, no
intermediate JSON contract — instead of forcing you into a JSON API plus a
single-page client framework.

This page compares the main members of that family.

## At a glance

| Project | Build step | Server affinity | Conceptual surface | Approx. JS shipped | Production-grade? |
|---|---|---|---|---|---|
| [HTMX](https://htmx.org) | None | Language-agnostic | Large (25+ `hx-*` attributes) | ~14 KB gz | Yes |
| [Hotwire/Turbo](https://hotwired.dev) | None (via Importmap) | Rails-first (also Rust, Node, Go ports) | Medium (Turbo Drive + Frames + Streams + Stimulus) | ~40 KB gz | Yes |
| [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view) | None | Elixir/Phoenix only | Medium (server-rendered + stateful WebSocket) | ~20 KB gz | Yes |
| [Unpoly](https://unpoly.com) | None | Language-agnostic, Rails-friendly | Medium-large (layers, fragments, navigation) | ~25 KB gz | Yes |
| **erbswap** | **None** | **Rails-friendly** | **Tiny (1 helper + 8 data attributes)** | **~1.5 KB gz** | **Demo / starter pattern** |

erbswap is the smallest viable member of this family. The point of the
comparison is to help you pick the *right* member, not to pitch erbswap as
better.

---

## Feature matrix

| Capability | HTMX | Turbo | LiveView | Unpoly | erbswap |
|---|:---:|:---:|:---:|:---:|:---:|
| Form swap | ✓ | ✓ | ✓ | ✓ | ✓ |
| Click-to-load swap | ✓ | ✓ | ✓ | ✓ | ✓ |
| Outer / inner swap modes | ✓ | ✓ | ✓ | ✓ | ✓ |
| Positional swap (`beforeend` etc.) | ✓ | partial | partial | ✓ | ✗ |
| Out-of-band swap (one response, many frames) | ✓ | ✓ (Turbo Streams) | ✓ | ✓ | ✗ |
| Browser history / `pushState` | ✓ | ✓ (Turbo Drive) | ✓ | ✓ | ✗ |
| WebSocket / SSE | extension | ✓ (Turbo Streams) | ✓ (built-in) | extension | ✗ |
| Request abort / retry / debounce | ✓ | partial | n/a (stateful) | ✓ | ✗ |
| Stateful UI without round trip | ✗ | partial (Stimulus) | ✓ | partial | ✗ |
| Polling | ✓ | ✗ | ✓ (live) | ✓ | ✗ |
| Layer / overlay system | ✗ | ✗ | ✗ | ✓ | ✗ |
| Single-flight CSS pattern (built-in) | ✓ (`hx-indicator`) | partial | n/a | ✓ | by convention |
| Zero dependencies | ✓ | requires turbo-rails | requires Phoenix | ✓ | **yes** |
| Zero build step | ✓ | yes (Importmap) | yes | ✓ | **yes** |

---

## Picking

### Pick HTMX when

You want the *full* hypermedia experience: out-of-band swaps, browser history,
debounced triggers, polling, animations, indicators, the works. HTMX is the
most mature project in this family and the conceptual surface is its strength,
not a problem.

You're polyglot. HTMX talks to Rails, Django, Phoenix, Go, Spring — anything
that can return HTML.

### Pick Hotwire/Turbo when

You're on Rails 7+ and the Turbo conventions are already familiar. Turbo
Streams gives you out-of-band updates and the `morph` swap mode handles
focus/scroll preservation. The `<turbo-frame>` custom element is a clean
mental model.

You want WebSocket-driven UI for parts of your app (Turbo Streams over Action
Cable).

### Pick Phoenix LiveView when

You're on Elixir/Phoenix. LiveView is in a different language but is the
closest in spirit to "server-driven UI" — the entire UI is server state,
streamed over a stateful WebSocket. Best-in-class for forms, validations,
multi-step flows.

### Pick Unpoly when

You like a richer Rails-friendly hypermedia API with layers / overlays /
fragments and want a fuller conceptual model than HTMX without buying into
Hotwire specifically.

### Pick erbswap when

- You want async swaps in a small, contained slice of your Rails app.
- You don't want to add a framework dependency for it.
- The full list of "[out of scope](INVARIANTS.md#4-out-of-scope)" is fine with
  you — and if any of it stops being fine, you're willing to migrate.
- You'd rather start with 195 lines of vanilla JS that you can read end-to-end
  in five minutes than learn 25+ `hx-*` attributes.

The most honest framing: erbswap is a **starting point**, not an
**alternative**. It works for as long as it works. When it stops working, you
have a clear migration path because your swaps are simple and your invariants
are documented.

---

## What erbswap is *not*

- Not a framework.
- Not a competitor to HTMX or Turbo. Both are larger, more mature, more
  featureful, and will outscale erbswap in any direction you care to grow.
- Not a fork or "lite" version of any of the above. The implementation is from
  scratch, but the *ideas* are entirely from the hypermedia school — credit to
  HTMX, Hotwire, LiveView, and Unpoly for shaping the design space.
