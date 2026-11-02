---
name: call-tree
description: Draw an ASCII call-tree diagram that shows the big picture of a file, module, feature, or pull request, including entry points, hubs, external calls, shared state, and boundaries (client/server, queues, database). Use when the user asks for a call tree, call graph, flow diagram, or "how does this fit together", or wants to see how a PR's changes fit into the codebase.
---

# ASCII call-tree diagrams

Draw call-tree diagrams that give the big picture of a module or feature. Treat
`$ARGUMENTS` as the file, feature, or pull request to diagram. If none is given
and it can't be inferred from context, ask.

For a pull request, follow [PR diagrams](#pr-diagrams-mark-changes-with-) as
well.

## Before drawing

1. **Read all of the code** being diagrammed. Don't draw from names alone.
2. **Find the entry points**: keymaps, routes, CLI commands, event handlers,
   exported functions, `main`. Each one becomes a root on the left.
3. **List the hubs**: functions with more than one caller.
4. **List the external calls**: libraries, APIs, shell commands, the database,
   network, and the file system.
5. **Find the shared state**: module variables, stores, caches, globals.
6. **Find the boundaries** the flow crosses (see
   [Boundaries](#boundaries-server-client-and-other)).

## Layout

### Columns, left to right = outside to inside to outside

Put a header row of columns, underlined with `─`:

```
 ENTRY POINTS          PUBLIC (M.*)          PRIVATE HELPERS          EXTERNAL
 ────────────          ────────────          ───────────────          ────────
```

- **Entry points:** how a user or system triggers the code (`<leader>gp`,
  `POST /orders`, `onClick`, `cron`)
- **Public:** exported functions or the module API
- **Private:** local helpers
- **External:** anything outside the code being diagrammed, aligned in one column
  on the right so the edges of the system read as one vertical line

Rename the columns to suit the codebase, for example
`ROUTES │ HANDLERS │ SERVICES │ DB` or `UI │ HOOKS │ API CLIENT │ SERVER`.

### Glyphs

| Glyph | Meaning |
| --- | --- |
| `──▶` | calls |
| `├─▶` / `└─▶` | one of several calls from a parent (last one uses `└`) |
| `│` | continues down to the parent's next call |
| `──────────▶ x` | long arrow: reaches across columns to an external call |
| `◀────┐ ... ┘` | back-reference: the same function reached again from somewhere else; draw it once and point back to it |
| `─ cond? ──▶` | branch taken only under a condition |
| `1.` `2.` `3.` | steps in order, when order matters |
| `(note)` | a short inline note on what or why |
| `"M  +12 -3  path"` | an example of the output, in quotes |
| `═══` | a boundary line (see below) |
| `- - ▶` | async, deferred or event-driven call (callback, `schedule`, queue, `await`) |
| `★` | changed in the PR (see [PR diagrams](#pr-diagrams-mark-changes-with-)) |

Use Unicode box-drawing characters (`─ │ ├ └ ┐ ┘ ▶ ◀ ═`), which line up in a
monospace font. Put the whole diagram in a fenced code block.

### Rules

- **Each function is drawn once.** When it's reached a second time, use a
  back-reference arrow instead of repeating its subtree.
- **Arguments only when they matter**: `toggle_linehl(true)` vs `(false)`.
  Otherwise drop them.
- **Show the command or query on external calls** (`diff --numstat -z`,
  `SELECT … FROM orders`, `GET /api/user`), but short.
- **Show conditions** where the flow branches (`state.enabled?`, `cache hit?`,
  `401?`).
- **Leave out noise**: logging, trivial getters, formatting helpers, unless
  they're the point.
- **Width: about 120 columns** at most, so it fits in a terminal without
  wrapping.
- **Big codebases:** one diagram per feature or entry point, not one for the
  whole repo. Collapse a deep subtree to `└─▶ saveOrder() … (see diagram 2)`.

## After the diagram: three short callouts

1. **Shared state:** what's stored, who writes it and who reads it.
2. **Hubs:** functions with several callers, and how many. These are where a
   change has the widest effect.
3. **The big picture:** one or two sentences on what each entry point really
   does and how they relate. This is the most important part.

Optional when they apply: **cycles** (A → B → A), **error paths** (what happens
when an external call fails), and **hot paths** (what runs on every keypress,
request or render).

## Boundaries: server, client and other

When the flow crosses a boundary, draw it as a **horizontal `═══` line** across
the diagram with a label. Everything above it runs on one side, everything below
on the other. The arrow that crosses it is the request; label it with the
protocol and the endpoint or message.

```
 CLIENT (browser)
 ──────────────────
 <CheckoutButton> onClick ──▶ useCheckout().submit()
                                 └─▶ api.post("/orders", cart)
                                        │
════════════════════════════════════════│══ HTTP  POST /orders  (JSON) ════════
                                        ▼
 SERVER (Node)
 ──────────────────
 router.post("/orders") ──▶ handleCheckout(req)
                              ├─▶ validateCart()
                              ├─▶ calculateTotal() ─▶ formatMoney()
                              ├─▶ saveOrder() ──────────────────────▶ DB  INSERT orders
                              └─ - - ▶ queue.publish("order.created")
                                            │
════════════════════════════════════════════│══════ QUEUE  order.created ═════
                                            ▼
 WORKER
 ──────────────────
 onOrderCreated() ──▶ sendReceipt() ────────────────────────────────▶ email API
```

### Boundary kinds to mark

| Boundary | Label it with |
| --- | --- |
| Client ↔ server | `HTTP GET /path`, `WebSocket msg`, `gRPC Service.Method`, `tRPC router.proc` |
| Server-side ↔ client-side rendering (Next.js, Remix) | `"use client"`, `server action`, `loader` / `getServerSideProps` |
| Service ↔ service | protocol + endpoint, and which service owns it |
| Process ↔ process | `spawn git …`, `stdio`, `IPC`, `postMessage` (workers, iframes, extensions) |
| App ↔ database | `SQL`, `ORM model.method`, `cache GET key` |
| Sync ↔ async | `queue topic`, `event name`, `cron`, `setTimeout` / `vim.schedule` |
| Trust boundary | `auth required`, `user input`, `untrusted`. Mark where input is validated |
| Editor ↔ plugin / LSP | `LSP textDocument/references`, `plugin API` |

### Boundary rules

- **What crosses the boundary** goes on the line: the method, path and payload
  shape (`{ cartId, items[] }`), not the full type.
- **Return trips** are only worth drawing when they matter (streaming,
  callbacks, webhooks). Draw them as an upward arrow `▲` on the right of the
  line.
- **Mark where data is validated or authorized** next to the crossing, e.g.
  `(zod schema)`, `(requireAuth)`. A trust boundary with no check is worth
  pointing out in the callouts.
- **One crossing per line** where possible. If the client calls the server in
  several places, list them as separate arrows across the same line, each
  labelled.
- In the callouts, add **"Crossings"**: how many times the flow crosses each
  boundary. Many round trips for one user action is often a finding by itself.

## PR diagrams: mark changes with ★

When the diagram is about a PR, the goal is to show **how the changes fit into
the larger codebase**, not just the changed code. Draw the surrounding,
unchanged flow as normal, and mark what the PR touches with `★`.

### Before drawing a PR diagram

1. Get the PR's changes against the merge base (the same comparison as GitHub's
   "Files changed"): `git diff $(git merge-base HEAD origin/HEAD)`.
2. List the changed functions, and whether each is new, modified or removed.
3. Walk **outward** from each one: up to its callers (who is affected) and down
   to what it calls (what it now depends on), until you reach an entry point.
   Those unchanged callers and entry points are the context.

### Marking

| Mark | Meaning |
| --- | --- |
| `★ fn()` | function added or modified in the PR |
| `★ fn()  (new)` | function added in the PR |
| `★ ──▶` | a call the PR added (existing functions, new connection) |
| `╳ fn()  (removed)` | function or call the PR removed. Only draw it when its absence matters |
| `fn()` (no mark) | unchanged context, shown so you can see where the changes sit |

- Put `★` **directly before** the name so the left edge of the changed parts
  lines up and is easy to scan.
- A changed function's whole subtree isn't marked; only the parts that changed.
- Draw unchanged branches only as deep as needed to show the connection.
  Collapse the rest to `…`.
- If a changed function is a **hub**, draw all of its callers, even unchanged
  ones. Those are the parts of the codebase that behave differently now.

### PR callouts

Add these after the usual callouts:

- **What the PR changes:** one line per `★`, saying what changed in it.
- **Who's affected:** the unchanged callers and entry points that reach a `★`
  (the blast radius). Note any that the PR's tests don't cover.
- **New dependencies:** anything a `★` now calls that it didn't before,
  especially across a boundary (a new API call, a new table, a new queue).

### Example

A PR that adds discount codes to checkout:

```
 ROUTES                  HANDLERS                  SERVICES                     EXTERNAL
 ──────                  ────────                  ────────                     ────────

 POST /checkout ───────▶ handleCheckout(req)
                           ├─▶ validateCart()
                           ├─▶ calculateTotal(cart, ★ code)
                           │     ├─▶ subtotal()
                           │     ├─▶ ★ applyDiscount(code)  (new)
                           │     │     └─▶ ★ findDiscount(code)  (new) ───────▶ DB  SELECT discounts
                           │     └─▶ addTax()
                           ├─▶ saveOrder() ─────────────────────────────────────▶ DB  INSERT orders
                           └─▶ sendReceipt() ─▶ ★ formatMoney()

 POST /refund ─────────▶ handleRefund(req)
                           └─▶ ★ formatMoney()  (same function, unchanged caller)
```

- **What the PR changes:** `calculateTotal` takes a discount `code`;
  `applyDiscount` and `findDiscount` are new; `formatMoney` now rounds half-up.
- **Who's affected:** `formatMoney` is a hub, so receipts **and** refunds
  change, even though the PR never mentions refunds.
- **New dependencies:** checkout now reads the `discounts` table.
