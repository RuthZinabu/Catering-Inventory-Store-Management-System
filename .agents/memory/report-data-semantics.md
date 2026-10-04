---
name: Report data semantics
description: Requirements for expiry, production, and consumption reporting in this project.
---

Reports should use stored expiry batches and production runs/servings. Keep kitchen quantities issued labeled as a usage proxy rather than measured consumption, and compare them with recipe ingredient estimates scaled to recorded production.

**Why:** The reporting requirement is to use recorded operating data without presenting recipe calculations as measured kitchen consumption.

**How to apply:** When changing Laravel report responses or Flutter report screens, preserve store/date scoping, show recorded production, and make missing production or expiry coverage visible.