# ParaliSetu — KVK/FPO Dashboard (Next.js)

**Stack:** Next.js 15 (App Router) · TypeScript · Tailwind CSS · MapLibre GL · Recharts

## Day 1 setup (Oct 8)

```bash
cd web/kvk-dashboard
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir
npm install maplibre-gl react-map-gl recharts date-fns
```

**Key pages:**
- `/map` — live FIRMS hotspot overlay + district burn trend (adapted from parali repo)
- `/machines` — machine availability and dispatch view
- `/bookings` — booking pipeline tracker (FSM state per booking)
- `/demand` — stubble supply vs buyer demand heatmap

> Read SPEC.md and docs/AGENT_RULES.md before writing any code.
> Adapted from parali repo (FIRMS route + MapLibre dashboard) with owner permission.
> See docs/COPIED_CODE.md for a full log of reused code.
