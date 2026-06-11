# Invariants

These rules are the load-bearing structure of erbswap. Without them, the
pattern collapses and the library grows into a 1,000-line internal framework.
The library does not enforce these — *you* do, in code review and in this
document.

If a change to your code would violate one of these, take that as a signal
that you've outgrown erbswap and need to move to HTMX or Turbo.

## 1. Same frame `id`, every state

Every partial that responds to a swap into a given frame **must** wrap in the
same `<div id="...">` as every other state's partial.

```erb
<%# _modal_initial.html.erb %>
<div id="task-frame">
  <%# initial markup %>
</div>

<%# _modal_success.html.erb %>
<div id="task-frame">
  <%# success markup %>
</div>

<%# _modal_empty.html.erb %>
<div id="task-frame">
  <%# empty markup %>
</div>

<%# _modal_error.html.erb %>
<div id="task-frame">
  <%# error markup %>
</div>
```

### Why

A target is a function of two things: the markup that introduced it (so
something on the page declares `data-erbswap-target="task-frame"`) and the
markup that responds to it (so the swap response can find an element with
`id="task-frame"` to swap into or replace).

With `swap="replace"` (the recommended mode), the response *becomes* the
target. The next swap then needs the same id to find its next target. If state
A uses `task-frame` and state B uses `task-result`, the second swap fails
silently because the target it was promised no longer exists.

### How to enforce

- Code review: scan every partial under a feature's directory and verify the
  outer id matches.
- A simple test: render each state partial and assert the outer element id.

## 2. Two swap modes only

Only `innerHTML` and `replace` (= `outerHTML`).

| Mode | What it does | When to use |
|---|---|---|
| `innerHTML` | Replaces the *children* of the target; the target wrapper stays. | Response renders only the inner content, not the wrapper. |
| `replace` | Replaces the target *itself* via `outerHTML`. | Response renders its own wrapper with the same id. **Recommended for consistency.** |

What's deliberately excluded: `beforeend`, `afterbegin`, `beforebegin`,
`afterend`, `none`, `morph`, OOB targeting.

### Why

Positional swaps require thinking about the difference between "this is the
target" and "this is where the target should go relative to the current DOM."
That's a meaningful conceptual surface area. erbswap is one bullet point —
"swap response into target" — and adding modes turns it into a paragraph.

If you need positional swap, you need the rest of HTMX too. Take the upgrade.

## 3. Single controller entry point

All erbswap responses go through one method:

```ruby
def render_erbswap(partial:, locals: {}, status: :ok)
  render partial: partial, locals: locals, formats: [:html], layout: false, status: status
end
```

That's it. No second helper. No JSON envelope. No response wrapper. No
`render_erbswap_modal`, `render_erbswap_inline`, `render_erbswap_oob`. One
method, one shape.

### Why

Once you have two response helpers, you have a vocabulary, and vocabularies
grow. Each helper means a code review conversation about which to use. By
fixing it to one method, you remove the conversation. The shape of every
erbswap response is identical and obvious.

### How to enforce

Grep your codebase. There should be exactly one `def render_erbswap` and zero
other helpers. If you see drift, push back.

## 4. Out of scope

erbswap does *not* implement:

- **Out-of-band swap.** One response updating multiple frames simultaneously.
- **Browser history.** `pushState`, `popstate`, URL rewriting.
- **SSE / WebSocket.** Streaming responses, real-time updates.
- **Request abort.** Cancelling in-flight fetches.
- **Retry.** Auto-retry on network failure.
- **Debounce / throttle.** Keystroke-triggered fetches with delay.
- **Polling.** Repeated fetches on a timer.
- **View transitions.** CSS view transition API integration.
- **Optimistic UI.** Client-side state mutated before server confirms.
- **Form serialization beyond `FormData`.** No custom encoders, no JSON bodies.

### Why

These features are *not* edge cases. They are exactly what HTMX, Turbo, and
the rest of the field have spent years building well. The moment you implement
one of them in erbswap, you've signed up to maintain it, and the next request
will be to implement another. Within a year the library is 1,000 lines and you
have rebuilt one of those projects, badly.

The single most valuable property of erbswap is the *no* to all of these.

### How to enforce

When someone (including you) wants to add one of these:

1. Re-read this section.
2. Pick HTMX or Turbo.
3. Migrate the use case.

The migration is cheap because you've kept the swaps simple. The longer you
postpone it, the more home-rolled half-features you have to unwind. So when
the signal comes, take it.

---

## What does *not* count as a violation

A few things look like growth but aren't:

- **Adding examples.** This repo's `app/views/` can grow.
- **Adding tests.** Always.
- **CSS hooks for new states.** As long as they're styling existing event
  states (loading, error), not new lifecycle events.
- **Tightening the existing API.** Bug fixes, clearer error messages, better
  CSRF handling. The 195 lines can shift a bit.

The line count of `erbswap.js` is a useful smell, not a hard rule. If it
drifts to 250 and every line is still on the four-bullet API surface, fine.
If it drifts to 250 because someone added retry logic — revert.
