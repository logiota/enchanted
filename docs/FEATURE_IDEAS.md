# Feature ideas

100 everyday features that would make Enchanted more useful. Each one says what it does and why it matters. Where a feature builds on existing code, the relevant file is named.

## Start here

These ten give the most everyday value for the effort:

- **#1 Services menu actions**: completions in every app without Accessibility permission.
- **#2 Paste instead of type**: faster, more reliable insertion of results.
- **#15 Search all conversations**: the most common way to get back to an old answer.
- **#16 Smart titles**: a readable sidebar.
- **#29 Model manager**: removes the need to use the terminal.
- **#32 Per-chat parameters**: chat is currently hard-coded to temperature 0.
- **#43 Attach documents**: the most common "can it read this?" request.
- **#63 Menu bar mode**: half-built already.
- **#83 Keychain for tokens**: a small change that is a real security improvement.
- **#100 First-run setup**: most people give up before they ever see a working chat.

## Everywhere on your Mac (completions)

1. **Services menu actions.** Expose completions as macOS Services, such as "Enchanted › Fix Grammar" in every app's right-click menu. Services hand text over through the system pasteboard, so they work without the Accessibility permission the panel needs today (`Helpers/Accessibility.swift`).
2. **Paste instead of type.** Insert results through the clipboard, then restore it, instead of simulated keystrokes (`Accessibility.swift`, `CGEvent` typing). This is instant for long text, handles emoji and non-Latin scripts, and doesn't drop characters.
3. **Preview before replacing.** Show the result as a diff against the selection: ⏎ replaces, ⌘C copies, Esc discards.
4. **Type-to-filter in the panel.** Once there are more than a dozen completions, typing filters the panel and ↑/↓ + ⏎ runs one. Single-letter shortcuts stay for favourites.
5. **Per-completion model.** Pick a model per completion, for example a coder model for code templates and a small, fast model for grammar fixes.
6. **Per-completion output.** Remember "respond in app", "type into window" or "copy to clipboard" per completion, instead of the global ⇧Space toggle.
7. **Direct hotkeys for favourites.** Give a single completion its own global shortcut (for example ⌃⌥G for Fix Grammar) that runs it without opening the panel.
8. **More template variables.** Add `{{clipboard}}`, `{{date}}`, `{{app}}` (the frontmost app) and `{{input:Target language}}`, which asks for a value at run time. `CompletionsPanelVM.constructPrompt` already handles `{{text}}`.
9. **Chain completions.** Save a sequence such as Fix Grammar → Make Shorter → Professional as one recipe.
10. **App-aware ordering.** Float the most relevant completions to the top based on the frontmost app: email templates in Mail, code templates in Xcode.
11. **Most-used first.** Count runs per completion and offer "sort by most used".
12. **Import and export completions.** Share a set of completions as a JSON file and import a teammate's set.
13. **Undo the last insertion.** One keystroke restores the original selection when a result is wrong.
14. **Run on the clipboard.** When nothing is selected, offer to run the completion on the clipboard instead of doing nothing.

## Conversations

15. **Search all conversations.** Full-text search across titles and messages (a SwiftData predicate on `MessageSD.content`), opened with ⌘F in the sidebar.
16. **Smart titles.** Ask the model for a 3–6 word title after the first reply. Today the title is the first prompt verbatim (`ConversationStore.sendPrompt`).
17. **Pin and favourite.** Keep important conversations at the top of the sidebar.
18. **Folders or tags.** Group conversations by project or topic.
19. **Regenerate with history.** Keep earlier answers when regenerating and switch between them (‹ 1/3 ›).
20. **Branch from any message.** Fork a conversation at a message to try another direction without losing the original.
21. **Continue generating.** One click continues a reply that stopped at the length limit.
22. **Export to a file.** Save a conversation as Markdown, PDF or JSON. Today it can only be copied to the clipboard (`Chat.copyChat`).
23. **Import from other apps.** Bring ChatGPT, Claude or Open WebUI exports into local history.
24. **Archive and undo delete.** Archive instead of deleting, with an Undo toast after a delete.
25. **Automatic cleanup.** Optionally archive or delete conversations older than N days.
26. **Draft autosave.** Keep unsent text per conversation when switching between them.
27. **Quote and ask.** Select part of a reply and ask a follow-up about just that passage.
28. **Message details.** Show the timestamp, model, token count and tokens per second for each reply (Ollama returns `eval_count` and `eval_duration`).

## Models and server

29. **Model manager.** Pull, delete and copy models in the app with download progress (`/api/pull`, `/api/delete`, `/api/copy`).
30. **Model details.** Show parameter count, quantisation, context length, family and license (`/api/show`).
31. **Capability detection.** Read vision, tools and thinking support from `/api/show` instead of the hard-coded `["llava"]` list in `LanguageModelSD`.
32. **Per-chat parameters.** Temperature, top-p, context size (`num_ctx`), maximum tokens and seed in a chat settings popover. Chat requests currently always use temperature 0 (`ConversationStore.swift`).
33. **Assistants.** Named presets that bundle a model, system prompt and parameters ("Coding buddy", "Spanish tutor"), chosen per chat.
34. **Free memory.** Unload a model on demand (`keep_alive: 0`) and choose how long models stay loaded.
35. **Running models.** Show which models are loaded and how much memory they use (`/api/ps`).
36. **Server profiles.** Save several endpoints (home, laptop, work), switch from the toolbar, and fall back automatically when one is unreachable.
37. **Find my server.** On first launch, check `localhost` and the local network for port 11434 so most people never type a URL.
38. **Connection doctor.** A diagnostics screen covering reachability, Ollama version (`/api/version`), latency and auth errors, with plain-language fixes.
39. **Context meter.** Show how full the context window is, and offer to summarise older messages when it's nearly full.
40. **Thinking controls.** Turn `think` on or off for reasoning models and choose whether reasoning starts collapsed. `<think>` tags are already parsed in `MessageSD`.
41. **Compare models.** Send one prompt to two models side by side and keep the better answer.
42. **OpenAI-compatible servers.** Support LM Studio, the llama.cpp server, vLLM and similar endpoints alongside Ollama.

## Input and attachments

43. **Attach documents.** Drop PDF, text, Markdown or code files into a chat. The text is extracted locally (PDFKit) and added to the prompt.
44. **Multiple images.** Attach several images to one message.
45. **Screenshot to prompt.** Capture a screen region straight into the prompt with a shortcut.
46. **Local OCR.** Extract text from images with the Vision framework so text-only models can read screenshots and photos.
47. **Paste a link.** Fetch a page's readable text into the prompt, shown as a "fetched from …" chip.
48. **Prompt history.** ↑ in an empty input recalls earlier prompts, as in a terminal.
49. **Slash commands.** `/summarize`, `/translate` and others in the chat box run completion templates on the draft or the last reply.
50. **Queue a follow-up.** Type and queue the next message while the model is still answering.
51. **Push-to-talk.** Hold a key to dictate and release to send, with an optional auto-send after a pause.
52. **Drop onto the icon.** Drag text or files onto the Dock or menu bar icon to start a chat with them.

## Reading and output

53. **Code block actions.** Next to Copy (`CodeBlockView`), add Save as File, Open in Editor and Run in Terminal (with confirmation).
54. **Math rendering.** Render LaTeX (`$…$` and `$$…$$`).
55. **Diagram rendering.** Render Mermaid code blocks as diagrams.
56. **Table export.** Copy a Markdown table as CSV or open it in Numbers.
57. **Better Read Aloud.** Speed control, highlighting of the sentence being spoken, and an option to read new replies automatically (`SpeechService`).
58. **Text size and density.** A font size setting and a compact message layout.
59. **Navigate long replies.** Collapse long messages and jump to the start of the latest reply.
60. **Clear errors with Retry.** Show why a request failed (timeout, missing model, auth) with a Retry button on the message.
61. **Share a reply.** A share sheet for a single reply (Messages, Mail, Notes).
62. **Find in conversation.** ⌘F inside a conversation, with matches highlighted.

## Mac integration

63. **Menu bar mode.** Finish the menu bar extra, which exists but is disabled with `#if false` in `EnchantedApp.swift`.
64. **Launch at login.** A toggle using `SMAppService`, so the panel hotkey works right after a restart.
65. **Notify when done.** A notification and Dock badge when a long reply finishes in the background.
66. **Spotlight search of chats.** Index conversations with Core Spotlight.
67. **Finder Quick Action.** "Summarize with Enchanted" for text and PDF files in Finder.
68. **Command palette.** ⌘K jumps to any conversation, model, setting or command.
69. **Keyboard navigation.** ⌘1–9 switches between recent conversations, ⌘[ and ⌘] move through history, and ⌘⌫ deletes after confirmation.
70. **Windows and tabs.** Open conversations in separate windows or tabs.
71. **URL scheme.** `enchanted://ask?prompt=…` and `enchanted://complete?name=…` for Raycast, Alfred and scripts.
72. **Shortcuts actions.** App Intents for "Ask Enchanted", "Run Completion" and "Summarize Text" in the Shortcuts app and Siri.

## iPhone, iPad and Vision Pro

73. **Share extension.** Send text, links, images or PDFs from any app to Enchanted.
74. **Keyboard extension.** Run completion templates in any text field on iOS, the iPhone equivalent of the Mac panel.
75. **Widgets.** A quick-ask widget and "continue last chat" on the Home Screen and Lock Screen.
76. **Action button and Control Center.** Start a voice question with one press (an App Intents control).
77. **Ask about a photo.** Take a photo and ask about it in one step with a vision model.
78. **iCloud sync.** Optional sync of conversations and completions between devices (SwiftData with CloudKit).
79. **Handoff.** Continue the current conversation on another device.
80. **Offline queue.** Show clearly when the server can't be reached, and send queued messages once it can.
81. **iPad keyboard shortcuts.** Full shortcut support with a discoverable shortcut overlay.
82. **Hands-free voice chat.** Back-and-forth voice conversation with interruption (barge-in) in Voice mode.

## Privacy and security

83. **Keychain for tokens.** Store the bearer token in the Keychain instead of `UserDefaults` (`@AppStorage("ollamaBearerToken")`).
84. **App lock.** Require Touch ID or Face ID to open the app or view history.
85. **Temporary chats.** Incognito conversations that are never saved.
86. **Custom headers.** Add arbitrary HTTP headers per server, for example for Cloudflare Access or an API gateway.
87. **Self-signed certificates.** Trust a specific self-signed certificate for a home server.
88. **Backup and restore.** Export all conversations, completions and settings to one file, and restore from it.
89. **Redact before sending.** Optionally mask email addresses, phone numbers and card-like numbers before a prompt leaves the device.
90. **Privacy overview.** One screen showing what is stored locally and which server receives prompts, with a button to clear each.
91. **Separate history per server.** Keep work and personal history apart by server profile.

## Personal productivity

92. **About me.** A short profile (name, role, preferences, writing style) added to the system prompt and editable in Settings.
93. **Saved chat prompts.** A prompt library with variables for the chat box, shared with completion templates.
94. **Send to Reminders and Calendar.** Turn action items or dates in a reply into reminders or calendar events (EventKit).
95. **Save to Notes or a folder.** Save a reply to Apple Notes, or as Markdown into a chosen folder such as an Obsidian vault.
96. **Chat with a folder.** Local retrieval over a folder of documents using an Ollama embedding model, so nothing leaves the machine.
97. **Simple tools.** Calculator, date and unit-conversion tools through Ollama tool calling, so small models get maths and dates right.
98. **Optional web search.** Answers that need current information can use a self-hosted SearXNG endpoint, with sources shown.
99. **Usage stats.** Messages and tokens per day and per model, plus average speed, to help pick the right model.
100. **First-run setup.** Detect the server, suggest models that fit the Mac's memory, pull one with progress, and land in a working chat.
