# Chat WebSocket — Frontend Actions & Events

This document describes the WebSocket API for the real-time chat feature: how to connect, what **actions** the frontend can **send**, and what **event types** the frontend will **receive**.

---

## Connection

- **URL:** `ws://<host>/ws/chat` or `wss://<host>/ws/chat` (path may be `ws/chat` or `ws/chat/`).
- **Authentication:** The WebSocket handshake must include the same authentication your app uses (e.g. session cookie or token, depending on your ASGI auth middleware). Unauthenticated connections are closed with code `4401`.
- **Token as query param:** The Flutter app passes the JWT access token as a query parameter:
  ```
  wss://<host>/ws/chat/?token=<access_token>
  ```
  Ensure the access token is valid (refresh if needed) before connecting.

After a successful connect, the server sends a **connected** event (see [Events you receive](#events-you-receive)).

---

## Message Format (What You Send)

Every message from the client must be **JSON** with this shape:

```json
{
  "action": "<action_name>",
  "payload": { ... }
}
```

- `**action**` (string, required): One of the actions listed below.
- `**payload**` (object, optional): Data for that action. Omit or use `{}` if the action needs no data.

If `action` is missing or not recognized, the server responds with:

```json
{ "type": "error", "message": "unknown_action" }
```

---

## Actions You Can Send

### 1. `request_chat`

**Who:** **Student** only.  
**Purpose:** Start a new chat session for a specific support node (e.g. "Unit 1", "Technical support").


| Payload key | Type   | Required | Description                                         |
| ----------- | ------ | -------- | --------------------------------------------------- |
| `node_id`   | string | ✅        | UUID of the `RealTimeChatNode` to request chat for. |


**Example:**

```json
{
  "action": "request_chat",
  "payload": { "node_id": "550e8400-e29b-41d4-a716-446655440000" }
}
```

**Possible responses:**

- **Success:** `type: "chat_request_created"` with `session_id` and `session` (see [Events you receive](#events-you-receive)).
- **Error:**  
  - `message: "forbidden"` — user is not a student.  
  - `message: "missing_node_id"` — `node_id` not sent.  
  - `message: "already_has_open_chat"` — student already has an open session; `detail.session_id` is the existing session.  
  - `message: "node_not_found"` (or similar) — invalid `node_id`.

---

### 2. `accept_chat`

**Who:** **Call center** only.  
**Purpose:** Assign the current call center user to a waiting chat session and mark it active. The student receives a welcome message and `chat_assigned`.


| Payload key  | Type   | Required | Description                         |
| ------------ | ------ | -------- | ----------------------------------- |
| `session_id` | string | ✅        | UUID of the chat session to accept. |


**Example:**

```json
{
  "action": "accept_chat",
  "payload": { "session_id": "660e8400-e29b-41d4-a716-446655440001" }
}
```

**Possible responses:**

- **Success:** `type: "chat_assigned"` with `session_id`, `session`, and `welcome_message`.
- **Already taken:** `type: "chat_already_assigned"` (no payload) — another agent already accepted this session.
- **Error:**  
  - `message: "forbidden"` — user is not call center.  
  - `message: "missing_session_id"` — `session_id` not sent.

---

### 3. `send_message`

**Who:** **Student** or **Call center** (only if they are part of that session).  
**Purpose:** Send a text message or reference an already-uploaded attachment in the chat.


| Payload key     | Type   | Required | Description                                                                                                                                                                        |
| --------------- | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `session_id`    | string | ✅        | UUID of the active chat session.                                                                                                                                                   |
| `text`          | string | optional | Message text. Use when sending a text message.                                                                                                                                     |
| `attachment_id` | string | optional | UUID of a `ChatMessage` created via the [attachment upload API](#attachment-upload). Use to "send" an already-uploaded file/image in the chat. If present, `text` is not required. |


- For a **text-only** message: send `session_id` and `text` (can be empty string; will be trimmed).
- For an **attachment-only** message: send `session_id` and `attachment_id` (the message was already created by upload; this action broadcasts it into the conversation).
- Students may send `attachment_id` only if the session has **attachments allowed** (see `set_attachment_permission`).

**Example (text):**

```json
{
  "action": "send_message",
  "payload": {
    "session_id": "660e8400-e29b-41d4-a716-446655440001",
    "text": "مرحباً، أحتاج مساعدة في الواجب."
  }
}
```

**Example (attachment):**

```json
{
  "action": "send_message",
  "payload": {
    "session_id": "660e8400-e29b-41d4-a716-446655440001",
    "attachment_id": "d1cdefe3-04ba-4d01-b8d9-4ac3ea49b21b"
  }
}
```

**Possible responses:**

- **Success:** `type: "message_sent"` with `message` (same shape as in [new_message](#new_message)).
- **Error:**  
  - `message: "missing_session_id"`  
  - `message: "invalid_session_or_forbidden"` — session not active or user not in the session.  
  - `message: "attachments_not_allowed"` — student sent `attachment_id` but attachments are disabled for this session.

---

### 4. `close_chat`

**Who:** **Student** (their own session) or **Call center** (sessions they are assigned to).  
**Purpose:** Close the chat session.


| Payload key       | Type   | Required | Description                                                              |
| ----------------- | ------ | -------- | ------------------------------------------------------------------------ |
| `session_id`      | string | ✅        | UUID of the chat session to close.                                       |
| `close_reason_id` | string | optional | UUID of a close reason from the [close reasons API](#close-reasons-api). |


**Example:**

```json
{
  "action": "close_chat",
  "payload": {
    "session_id": "660e8400-e29b-41d4-a716-446655440001",
    "close_reason_id": "880e8400-e29b-41d4-a716-446655440003"
  }
}
```

**Possible responses:**

- **Success:** `type: "chat_closed"` with `session_id`.
- **Error:**  
  - `message: "missing_session_id"`  
  - `message: "not_found"` — session does not exist.  
  - `message: "forbidden"` — user is not the student or the assigned call center.  
  - `message: "already_closed"` — session is already closed.

---

### 5. `set_attachment_permission`

**Who:** **Call center** only (and only for sessions they are assigned to).  
**Purpose:** Allow or disallow the student to send attachments in this session.


| Payload key  | Type    | Required | Description                                                            |
| ------------ | ------- | -------- | ---------------------------------------------------------------------- |
| `session_id` | string  | ✅        | UUID of the active chat session.                                       |
| `allow`      | boolean | optional | `true` to allow attachments, `false` to disallow. Defaults to `false`. |


**Example (allow student uploads):**

```json
{
  "action": "set_attachment_permission",
  "payload": {
    "session_id": "660e8400-e29b-41d4-a716-446655440001",
    "allow": true
  }
}
```

**Example (revoke student uploads):**

```json
{
  "action": "set_attachment_permission",
  "payload": {
    "session_id": "660e8400-e29b-41d4-a716-446655440001",
    "allow": false
  }
}
```

Call center agents should still be able to send their own attachments over REST/`send_message` where the backend allows it; `allow` only controls whether the **student** may attach.

**Possible responses:**

- **Success:** `type: "attachment_permission_changed"` with `session_id` and `allow`.
- **Error:**  
  - `message: "forbidden"` — user is not call center or not assigned to this session.  
  - `message: "missing_session_id"`  
  - `message: "not_found"` — session not found or not active.

---

## Events You Receive

All server → client messages are JSON with a `**type`** field. Handle them in your WebSocket `onMessage` handler.


| `type`                          | When it is sent                                                                                                                                                   | Payload shape (summary)                                                                                                             |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `connected`                     | Right after connect.                                                                                                                                              | `role`, `user`, and for students optionally `current_session`.                                                                      |
| `error`                         | Invalid action or payload.                                                                                                                                        | `message` (e.g. `"forbidden"`, `"missing_node_id"`, `"unknown_action"`), sometimes `detail`.                                        |
| `chat_request_created`          | Student sent `request_chat` successfully.                                                                                                                         | `session_id`, `session` (includes `status`, `allow_attachments`, `node_id`).                                                        |
| `chat_assigned`                 | Call center sent `accept_chat` successfully, or broadcast to student when their chat is assigned, or to other call center agents when someone else took the chat. | `session_id`, and either `call_center` + `welcome_message` (student / accepting agent) or `assigned_to_other: true` (other agents). |
| `chat_already_assigned`         | Call center sent `accept_chat` but session was already accepted.                                                                                                  | No extra fields.                                                                                                                    |
| `message_sent`                  | Your `send_message` was accepted.                                                                                                                                 | `message` (id, sender, message_type, text, file_url, created_at).                                                                   |
| `new_message`                   | A new message was sent in a session you are in (by you or the other party).                                                                                       | `message` (same shape as above).                                                                                                    |
| `chat_closed`                   | A session was closed (by you or the other party).                                                                                                                 | `session_id`.                                                                                                                       |
| `attachment_permission_changed` | Call center changed attachment permission, or you received the broadcast.                                                                                         | `session_id`, `allow`.                                                                                                              |
| `new_chat_request`              | (Call center only.) A student requested a chat on a node you are assigned to.                                                                                     | `session_id`, `student` (id, full_name, generation_id, generation_name, city_id, city_name), `node_id`, `node_title`, `created_at`. |


### Connected payloads

- **Student:**  
`role: "student"`, `user: { id, full_name }`, and optionally `current_session: { session_id, status, allow_attachments, call_center }` if they have an open session.
- **Call center:**  
`role: "call_center"`, `user: { id, full_name }`.

### Message object (in `message_sent` / `new_message`)

```ts
{
  id: string;           // UUID
  sender: { id: string; full_name: string };
  message_type: "text" | "image" | "file";
  text: string;
  file_url: string | null;  // absolute or relative URL to file; null for text-only
  created_at: string;       // ISO 8601
}
```

---

## REST APIs Used With Chat

### Close reasons API

Before closing a chat, the frontend can fetch the list of close reasons (for dropdowns, etc.):

- **Endpoint:** `GET /api/chat/close-reasons` (or your mounted path for the chat app).
- **Response:** Array of `{ id, name, description, is_active, is_call_center_reason, is_student_reason }`. Use `id` as `close_reason_id` in the `close_chat` action.

### Attachment upload

Attachments are created via REST, then referenced in `send_message` with `attachment_id`:

1. **Upload:** `POST /api/chat/upload` (or your chat base path) with:
  - `session_id` (form or query)
  - `file` (multipart file)
2. **Response:** 201 with the created message object (includes `id`).
3. **Send in chat:** Send a WebSocket message with `action: "send_message"` and `payload: { session_id, attachment_id: "<id from step 2>" }`.

Students may only upload if the session has `allow_attachments === true` (call center can set this via `set_attachment_permission`).

---

## Quick Reference: Actions by Role


| Action                      | Student | Call center |
| --------------------------- | ------- | ----------- |
| `request_chat`              | ✅       | ❌           |
| `accept_chat`               | ❌       | ✅           |
| `send_message`              | ✅       | ✅           |
| `close_chat`                | ✅       | ✅           |
| `set_attachment_permission` | ❌       | ✅           |


All IDs (`node_id`, `session_id`, `attachment_id`, `close_reason_id`) are UUIDs sent as strings.