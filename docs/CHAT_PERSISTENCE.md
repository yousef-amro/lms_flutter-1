# Why Chats Disappear After Restart

## Cause

Chats disappear when you close and reopen the app because **nothing is persisted** and **the server does not send past chats on reconnect**.

### 1. In-memory only

- **`ChatController.incomingRequests`** – list of pending chat requests (call center). Filled only when the WebSocket sends a **`new_chat_request`** event.
- **`ChatController.messages`** – messages in the current session. Filled only when **`message_sent`** / **`new_message`** arrive.

When the app process is killed, this state is lost. On next launch, both lists start empty.

### 2. No chat list on connect

From `WEBSOCKET_ACTIONS.md`:

- **Call center:** The `connected` event only sends `role` and `user`. It does **not** send a list of pending or past chat requests.
- **Student:** The `connected` event can include `current_session` (one open session), but there is no “list of my past sessions” or “conversation history” in the WebSocket API.

So after reconnect the app has no way to repopulate “old” chats from the server.

### 3. No local persistence

The app does not save `incomingRequests` or `messages` to disk (e.g. SharedPreferences, Hive, SQLite). After restart there is no local copy to restore.

---

## Options to Fix

### A. Backend: send chat list on connect (recommended)

For **call center**, extend the `connected` event (or a follow-up event) to include:

- Pending (unassigned) chat requests, and/or  
- Recent / assigned sessions for this agent  

The app would then push these into `incomingRequests` (and optionally a “recent sessions” list) when handling `connected`, so after restart the list is filled from the server.

For **conversation history**, the backend can:

- Include the last N messages in `current_session` for students, or  
- Expose a REST endpoint like `GET /api/chat/sessions` and `GET /api/chat/sessions/:id/messages` so the app can load session list and history after login/reconnect.

### B. App: persist pending requests locally

- When a **`new_chat_request`** is received, save it (e.g. to SharedPreferences/Hive) with a timestamp.
- In **`ChatController.onInit`** (or after WebSocket connect), load saved requests and merge into `incomingRequests`.
- Optionally clear or mark as “stale” after some time or when the server sends that the request was assigned/closed.

This keeps pending requests across restarts but does not replace server-side history or a proper “chat list” API.

---

## Summary

| What                    | Why it’s empty after restart                    |
|-------------------------|-------------------------------------------------|
| Pending chat requests   | Only live in memory; server doesn’t resend list |
| Messages in a session   | Only live in memory; no history fetch on connect|
| Local storage           | Not used for chat list or messages              |

To have chats survive app restart, either the **backend** sends a chat list (and optionally history) on connect or via REST, and/or the **app** persists pending requests (and optionally messages) locally.
