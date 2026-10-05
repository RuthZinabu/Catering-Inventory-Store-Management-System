---
name: User activity scope
description: Requirement for the Recent Activity section in user profiles.
---

The Recent Activity section in a user's detail screen must show only actions attributed to that selected user, not a global activity feed.

**Why:** The user explicitly asked to see only that person's activity in their profile.

**How to apply:** Scope activity records by the selected user's actor/creator field on the backend. Do not fill the section with global events or unrelated users' actions.
