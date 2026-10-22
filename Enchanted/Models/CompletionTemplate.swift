//
//  CompletionTemplate.swift
//  Enchanted
//

import Foundation

/// A ready-made completion from the Template Library that users can add to their own completions.
struct CompletionTemplate: Identifiable, Hashable {
    enum Category: String, CaseIterable, Identifiable {
        case writing = "Writing & Editing"
        case tone = "Tone & Style"
        case summarize = "Summarize & Analyze"
        case email = "Email & Messages"
        case work = "Work & Meetings"
        case code = "Code"
        case data = "Data & Formatting"
        case learn = "Learn & Explain"
        case language = "Language & Translation"
        case everyday = "Everyday & Personal"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .writing: return "pencil.line"
            case .tone: return "theatermasks"
            case .summarize: return "text.magnifyingglass"
            case .email: return "envelope"
            case .work: return "briefcase"
            case .code: return "chevron.left.forwardslash.chevron.right"
            case .data: return "tablecells"
            case .learn: return "graduationcap"
            case .language: return "globe"
            case .everyday: return "house"
            }
        }
    }

    /// What the model should return. Completions can be typed straight into the frontmost app,
    /// so anything meant to replace the selection must come back without commentary.
    enum Output {
        case replace
        case message
        case answer
        case code
        case data
        case translation

        var rule: String {
            switch self {
            case .replace:
                return "Reply with only the resulting text, with no preamble, explanation or surrounding quotes. Keep the original language and formatting."
            case .message:
                return "Reply with only the message, ready to send, with no preamble or explanation. Use [brackets] for details you don't know."
            case .answer:
                return "Be concise and skip any introduction or closing remarks. Use Markdown where it helps readability."
            case .code:
                return "Reply with only the code, with no explanation and no Markdown code fences."
            case .data:
                return "Reply with only the result, with no explanation and no Markdown code fences."
            case .translation:
                return "Reply with only the translation, with no notes or explanation. Preserve formatting, names, numbers and placeholders."
            }
        }
    }

    let name: String
    let category: Category
    let suggestedKey: Character
    let temperature: Float
    let output: Output
    /// The task in plain words, shown in the library and used for search.
    let task: String

    var id: String { category.rawValue + "/" + name }

    /// The full prompt stored on the completion. `{{text}}` is replaced with the selected text.
    var instruction: String {
        "\(task) \(output.rule)\n\nText:\n\"\"\"\n{{text}}\n\"\"\""
    }
}

// MARK: - Keyboard shortcut
extension CompletionTemplate {
    private static let shortcutKeys = "abcdefghijklmnopqrstuvwxyz0123456789".map(String.init)
    
    /// The suggested key if it's free, otherwise the first free letter from the name, then any free letter or digit.
    func availableKey(excluding usedKeys: Set<String>) -> String {
        let candidates = [String(suggestedKey)] + name.lowercased().map(String.init) + Self.shortcutKeys
        return candidates.first { Self.shortcutKeys.contains($0) && !usedKeys.contains($0) } ?? String(suggestedKey)
    }
}

// MARK: - Library
extension CompletionTemplate {
    static let all: [CompletionTemplate] = writing + tone + summarize + email + work + code + data + learn + language + everyday

    private typealias Entry = (name: String, key: Character, temperature: Float, output: Output, task: String)

    private static func templates(_ category: Category, _ entries: [Entry]) -> [CompletionTemplate] {
        entries.map {
            CompletionTemplate(name: $0.name, category: category, suggestedKey: $0.key, temperature: $0.temperature, output: $0.output, task: $0.task)
        }
    }

    private static func translation(_ language: String, _ key: Character) -> Entry {
        ("Translate to \(language)", key, 0.2, .translation, "Translate the text below into natural, fluent \(language).")
    }

    static let writing = templates(.writing, [
        ("Fix Grammar & Spelling", "f", 0.2, .replace, "Correct the grammar, spelling and punctuation of the text below. Change as little as possible and keep the author's voice."),
        ("Proofread & Explain", "p", 0.2, .answer, "Proofread the text below. List each error with the original phrase, the correction and a short reason. If there are no errors, say so."),
        ("Improve Writing", "i", 0.5, .replace, "Improve the clarity, flow and readability of the text below while keeping its meaning, tone and approximate length."),
        ("Make Shorter", "s", 0.3, .replace, "Rewrite the text below to be about half as long. Keep every important point and cut repetition, filler and hedging."),
        ("Make Longer", "l", 0.7, .replace, "Expand the text below to roughly twice its length with relevant detail, examples and explanation. Do not invent facts, names or figures."),
        ("Simplify Language", "y", 0.4, .replace, "Rewrite the text below in plain language: short sentences, common words and no unnecessary complexity."),
        ("Rephrase", "r", 0.7, .replace, "Rephrase the text below using different wording and sentence structure while keeping exactly the same meaning and tone."),
        ("Three Alternatives", "3", 0.9, .answer, "Write three alternative versions of the text below, each with a different approach (for example more concise, more vivid, more formal). Number them."),
        ("Continue Writing", "c", 0.8, .replace, "Continue the text below naturally for one or two paragraphs, matching its style, tone and point of view. Return only the new text, not the original."),
        ("Active Voice", "a", 0.3, .replace, "Rewrite the text below in the active voice wherever that makes it clearer and more direct."),
        ("Remove Filler Words", "w", 0.2, .replace, "Remove filler words, redundancies, hedges (such as 'just', 'really', 'very', 'I think') and unnecessary qualifiers from the text below without changing its meaning."),
        ("Remove Jargon", "j", 0.4, .replace, "Replace jargon, acronyms and technical terms in the text below with plain words a general reader understands."),
        ("Break Into Paragraphs", "b", 0.1, .replace, "Split the text below into well-organised paragraphs. Do not change the wording except for minimal punctuation fixes."),
        ("Stronger Opening", "o", 0.7, .replace, "Rewrite the first one or two sentences of the text below so they grab the reader's attention. Keep the rest unchanged."),
        ("Write a Conclusion", "n", 0.6, .replace, "Write a short concluding paragraph for the text below that ties together its main points and ends with a clear final thought. Return only the conclusion."),
        ("Headline Ideas", "h", 0.9, .answer, "Suggest 7 headline or title options for the text below, from straightforward to catchy, as a numbered list."),
        ("Vary Sentence Rhythm", "v", 0.6, .replace, "Rewrite the text below so sentence lengths and structures vary and it reads more naturally aloud. Keep the meaning."),
        ("Fix Punctuation Only", "u", 0.1, .replace, "Fix only the punctuation and capitalisation in the text below. Do not change any words."),
        ("Notes to Prose", "t", 0.5, .replace, "Turn the bullet points or rough notes below into flowing, well-connected paragraphs."),
        ("Clarity Check", "k", 0.3, .answer, "Point out sentences in the text below that are ambiguous, confusing or hard to follow, and suggest a clearer version of each."),
    ])

    static let tone = templates(.tone, [
        ("Professional", "p", 0.5, .replace, "Rewrite the text below in a professional, polished tone suitable for the workplace."),
        ("Friendly", "f", 0.6, .replace, "Rewrite the text below in a warm, friendly and approachable tone."),
        ("Casual", "c", 0.6, .replace, "Rewrite the text below in a relaxed, conversational tone, as if talking to a friend."),
        ("Formal", "o", 0.4, .replace, "Rewrite the text below in a formal tone suitable for official letters and academic or legal contexts."),
        ("Confident", "n", 0.5, .replace, "Rewrite the text below to sound confident and decisive. Remove hedging, excessive apologies and self-doubt while staying respectful."),
        ("Diplomatic", "d", 0.5, .replace, "Rewrite the text below to be diplomatic and tactful, softening criticism while keeping the core message clear."),
        ("Empathetic", "e", 0.6, .replace, "Rewrite the text below to be empathetic, acknowledging the reader's feelings and perspective."),
        ("Persuasive", "s", 0.6, .replace, "Rewrite the text below to be more persuasive, with clear benefits, strong reasoning and a compelling call to action. Do not exaggerate or invent claims."),
        ("Enthusiastic", "z", 0.7, .replace, "Rewrite the text below with genuine enthusiasm and energy, without sounding over the top."),
        ("Neutral & Objective", "u", 0.3, .replace, "Rewrite the text below in a neutral, objective tone. Remove emotional language, bias and opinion."),
        ("Witty", "w", 0.9, .replace, "Rewrite the text below with light, tasteful humour while keeping the message intact."),
        ("Direct", "r", 0.4, .replace, "Rewrite the text below to be direct and to the point. Lead with the main message and remove anything unnecessary."),
        ("Polite", "l", 0.5, .replace, "Rewrite the text below to be more polite and courteous without changing what it asks for or says."),
        ("Apologetic", "a", 0.5, .replace, "Rewrite the text below to sound sincerely apologetic, taking responsibility without making excuses."),
        ("Encouraging", "g", 0.6, .replace, "Rewrite the text below to be encouraging and supportive, highlighting strengths and framing next steps positively."),
        ("Calm & De-escalating", "m", 0.4, .replace, "Rewrite the text below to calm tensions: remove blame, sarcasm and defensive language, and focus on facts and solutions."),
        ("Bottom Line Up Front", "b", 0.3, .replace, "Rewrite the text below for a busy executive: the conclusion or ask first, then the key supporting points, in as few words as possible."),
        ("Inclusive Language", "i", 0.3, .replace, "Rewrite the text below using inclusive, gender-neutral and respectful language. Keep everything else unchanged."),
        ("Storytelling", "y", 0.8, .replace, "Rewrite the text below as a short, engaging narrative with a clear beginning, tension and resolution, keeping all the facts."),
        ("Humble", "h", 0.5, .replace, "Rewrite the text below to sound modest and humble while still communicating achievements clearly."),
    ])

    static let summarize = templates(.summarize, [
        ("Summarize", "s", 0.3, .answer, "Summarize the text below as concise bullet points covering only the key facts and core arguments."),
        ("TL;DR", "t", 0.3, .answer, "Give a one-sentence TL;DR of the text below."),
        ("Key Takeaways", "k", 0.3, .answer, "List the 3 to 7 most important takeaways from the text below, each as a short bullet."),
        ("Executive Summary", "e", 0.3, .answer, "Write an executive summary of the text below: a one-line overview, key points, implications and any recommended actions, in under 150 words."),
        ("Summary in 3 Sentences", "3", 0.3, .answer, "Summarize the text below in exactly three clear sentences."),
        ("Outline", "o", 0.2, .answer, "Create a hierarchical outline of the text below using headings and nested bullet points."),
        ("Pros & Cons", "p", 0.4, .answer, "List the pros and cons of what the text below describes as two bulleted lists, then give a one-line balanced verdict."),
        ("Main Argument", "m", 0.3, .answer, "Identify the main argument or thesis of the text below, then list the evidence and reasoning used to support it."),
        ("Hidden Assumptions", "a", 0.4, .answer, "Identify the unstated assumptions the text below relies on and briefly explain why each one matters."),
        ("Counterarguments", "c", 0.6, .answer, "Give the strongest counterarguments to the position in the text below, each with a short explanation."),
        ("Claims to Verify", "v", 0.2, .answer, "List every factual claim, statistic or figure in the text below that should be fact-checked, with what to verify and why it may be questionable. Don't judge whether claims are true unless it's common knowledge."),
        ("Sentiment & Tone", "n", 0.2, .answer, "Analyse the sentiment and tone of the text below: overall sentiment, emotions expressed and how it is likely to be received. Quote the phrases that support your analysis."),
        ("Who, What, When, Where", "w", 0.2, .answer, "Extract the key facts from the text below: who, what, when, where, why and how. Write 'not stated' where the text doesn't say."),
        ("Timeline", "l", 0.2, .answer, "Extract the events in the text below and arrange them as a chronological timeline with dates or relative times."),
        ("Questions to Ask", "q", 0.6, .answer, "Write the questions a careful reader should ask after reading the text below, focusing on gaps, risks and unclear points."),
        ("Find Contradictions", "f", 0.2, .answer, "Find any contradictions, inconsistencies or logical gaps in the text below. Quote the conflicting parts and explain the problem. If there are none, say so."),
        ("Constructive Critique", "r", 0.5, .answer, "Give constructive feedback on the text below: what works well, what is weak, and specific suggestions to improve it."),
        ("Why It Matters", "i", 0.5, .answer, "Explain the practical implications of the text below: why it matters, who it affects and what might happen next."),
        ("Compare Options", "d", 0.3, .answer, "Compare the options, items or viewpoints in the text below in a Markdown table, then summarize the key differences."),
        ("Bias Check", "b", 0.3, .answer, "Assess the text below for bias, loaded language and one-sidedness. Point out examples and describe what a more balanced version would include."),
    ])

    static let email = templates(.email, [
        ("Reply to Email", "r", 0.6, .message, "Write a clear, polite reply to the email below that addresses every question or request in it."),
        ("Politely Decline", "d", 0.6, .message, "Write a short, polite reply declining the request or offer below. Be gracious and, where appropriate, leave the door open for the future."),
        ("Accept & Confirm", "a", 0.5, .message, "Write a short reply accepting the invitation or request below and confirming the key details (date, time, place and next steps)."),
        ("Follow Up", "f", 0.5, .message, "Write a brief, friendly follow-up to the message below for someone who hasn't replied yet. Restate the request and make it easy to answer."),
        ("Gentle Reminder", "g", 0.5, .message, "Write a polite reminder about the deadline, task or request described below, without sounding pushy."),
        ("Thank You", "t", 0.7, .message, "Write a sincere, specific thank-you message based on the text below."),
        ("Apologize", "s", 0.5, .message, "Write a sincere apology for the situation below: acknowledge what happened, take responsibility and say how it will be put right."),
        ("Ask for Clarification", "q", 0.4, .message, "Write a polite reply asking for clarification on the unclear points in the message below, listing the specific questions."),
        ("Request Information", "i", 0.4, .message, "Write a concise, polite message requesting the information described below, explaining why it's needed and by when."),
        ("Introduce Two People", "n", 0.6, .message, "Write a short introduction email connecting the people described below, explaining who each is and why they should talk."),
        ("Cold Outreach", "o", 0.7, .message, "Write a short, personalised cold outreach email from the notes below. Lead with value for the recipient, keep it under 120 words and end with one clear, low-effort ask."),
        ("Negotiate", "e", 0.5, .message, "Write a polite but firm reply negotiating better terms on the message below. Acknowledge their position, state what you want and why, and propose a specific alternative."),
        ("Write a Complaint", "c", 0.4, .message, "Write a clear, firm and polite complaint from the notes below: what happened, its impact and the specific resolution requested."),
        ("Customer Support Reply", "u", 0.5, .message, "Write a helpful, empathetic customer support reply to the message below. Acknowledge the issue, explain next steps clearly and never blame the customer."),
        ("Out of Office", "x", 0.4, .message, "Write an out-of-office auto-reply from the details below (dates, reason if given, backup contact)."),
        ("Make It a Chat Message", "m", 0.5, .message, "Rewrite the email or text below as a short, natural chat message suitable for Slack or Teams."),
        ("Subject Lines", "l", 0.8, .answer, "Suggest 5 clear, specific subject lines for the email below."),
        ("Team Announcement", "h", 0.5, .message, "Write a clear team announcement from the notes below: what is changing, why, when, and what people need to do."),
        ("Congratulate", "b", 0.8, .message, "Write a warm congratulations message based on the news below."),
        ("Decline a Meeting", "v", 0.5, .message, "Write a polite reply declining the meeting below and suggest an alternative, such as an async update or a different time."),
    ])

    static let work = templates(.work, [
        ("Meeting Notes", "n", 0.3, .answer, "Turn the raw meeting notes or transcript below into clean notes with these sections: Summary, Decisions, Action Items (owner, due date) and Open Questions."),
        ("Action Items", "a", 0.2, .data, "Extract every action item from the text below as a checklist in the form '- [ ] Owner — task — due date'. Use 'Unassigned' or 'No date' when missing."),
        ("Meeting Agenda", "g", 0.5, .answer, "Create a focused meeting agenda from the topics below with a time allocation and goal for each item, plus the desired outcome of the meeting."),
        ("Status Update", "u", 0.4, .answer, "Turn the notes below into a concise status update with these sections: Done, In Progress, Next and Blockers/Risks."),
        ("Daily Standup", "d", 0.3, .answer, "Turn the notes below into a short standup update: Yesterday, Today and Blockers, one line per item."),
        ("Project Brief", "b", 0.5, .answer, "Write a one-page project brief from the notes below with Background, Goal, Scope (in and out), Success Metrics, Stakeholders, Timeline and Risks. Mark unknowns as TBD."),
        ("Decision Memo", "m", 0.4, .answer, "Write a short decision memo from the text below: Context, Options considered (with trade-offs), Decision, Rationale and Next steps."),
        ("Risks & Mitigations", "r", 0.4, .answer, "Identify the main risks in the plan below and propose a mitigation for each, as a table with Risk, Likelihood, Impact and Mitigation."),
        ("Break Down Task", "k", 0.4, .answer, "Break the task below into small, concrete, ordered steps that each take under an hour. Note any dependencies."),
        ("Prioritize", "p", 0.3, .answer, "Prioritize the list below using the Eisenhower matrix (urgent vs. important) and say what to do first, schedule, delegate or drop."),
        ("SMART Goals", "s", 0.4, .answer, "Rewrite the goals below as SMART goals: specific, measurable, achievable, relevant and time-bound."),
        ("User Stories", "y", 0.4, .answer, "Turn the feature description below into user stories ('As a …, I want …, so that …') with acceptance criteria for each."),
        ("Feedback (SBI)", "f", 0.5, .replace, "Rewrite the feedback below using the Situation–Behaviour–Impact model, keeping it specific, fair and actionable."),
        ("Self-Review", "v", 0.5, .answer, "Turn the notes below into a self-review covering accomplishments, impact (with metrics where given), growth areas and goals. Don't invent results."),
        ("Interview Questions", "q", 0.6, .answer, "Write 10 interview questions for the role or skills described below, mixing behavioural and practical questions, each with what a strong answer looks like."),
        ("Job Post", "j", 0.6, .answer, "Write a clear, inclusive job post from the notes below: summary, responsibilities, requirements, nice-to-haves and what the company offers."),
        ("Presentation Outline", "o", 0.5, .answer, "Turn the text below into a slide-by-slide presentation outline: a title, 3 or 4 bullet points and a speaker note for each slide."),
        ("FAQ", "h", 0.4, .answer, "Write an FAQ from the text below: the questions readers are most likely to ask, each with a short answer based only on the text."),
        ("Retrospective", "t", 0.4, .answer, "Organize the notes below into a retrospective: What went well, What didn't, What we learned and Action items."),
        ("Proposal", "l", 0.6, .answer, "Write a persuasive proposal from the notes below covering the problem, proposed solution, benefits, cost or effort, timeline and a clear ask."),
    ])

    static let code = templates(.code, [
        ("Explain Code", "e", 0.2, .answer, "Explain what the code below does, step by step, including its inputs, outputs and any non-obvious logic."),
        ("Find Bugs", "b", 0.2, .answer, "Review the code below for bugs, unhandled edge cases and incorrect logic. For each issue give the snippet, what goes wrong and a fix."),
        ("Code Review", "r", 0.3, .answer, "Review the code below like a senior engineer, covering correctness, readability, naming, error handling, performance and security. List the most important issues first."),
        ("Add Comments", "c", 0.2, .code, "Add concise comments to the code below that explain intent and non-obvious logic. Do not change the code itself."),
        ("Add Documentation", "d", 0.2, .code, "Add documentation comments to every public function, type and method in the code below, in the idiomatic style for its language. Do not change the code itself."),
        ("Refactor", "f", 0.3, .code, "Refactor the code below for readability and maintainability without changing its behaviour. Keep the same language and public interface."),
        ("Simplify Code", "s", 0.3, .code, "Simplify the code below by removing duplication and unnecessary complexity while keeping its behaviour identical."),
        ("Optimize Performance", "o", 0.2, .answer, "Optimize the code below for performance. Show the improved code, then briefly list what changed and why."),
        ("Write Unit Tests", "t", 0.3, .code, "Write thorough unit tests for the code below using the most common testing framework for its language, covering normal, edge and error cases."),
        ("Add Error Handling", "h", 0.3, .code, "Add robust error handling and input validation to the code below, following the conventions of its language."),
        ("Add Types", "y", 0.2, .code, "Add precise type annotations to the code below (for example TypeScript types or Python type hints) without changing its behaviour."),
        ("Convert to Python", "p", 0.2, .code, "Convert the code below to idiomatic Python 3, preserving its behaviour."),
        ("Convert to TypeScript", "j", 0.2, .code, "Convert the code below to idiomatic TypeScript, preserving its behaviour."),
        ("Convert to Swift", "w", 0.2, .code, "Convert the code below to idiomatic, modern Swift, preserving its behaviour."),
        ("Explain Error", "x", 0.3, .answer, "Explain the error message or stack trace below: what it means, the most likely causes and how to fix it."),
        ("Commit Message", "m", 0.3, .data, "Write a commit message for the diff or change description below: an imperative subject line under 72 characters, a blank line, then a short body explaining what changed and why."),
        ("Pull Request Description", "u", 0.4, .answer, "Write a pull request description for the diff or notes below with these sections: Summary, Changes, How to Test and Risks."),
        ("Write a Regex", "g", 0.2, .answer, "Write a regular expression that matches what is described below. Show the regex, explain each part, and give examples that should and shouldn't match."),
        ("Write SQL", "q", 0.2, .answer, "Write a SQL query for the request below. State any assumptions about table and column names and briefly explain the query."),
        ("Shell Command", "z", 0.2, .answer, "Write a macOS zsh command that does what is described below. Explain each part and warn about anything destructive."),
    ])

    static let data = templates(.data, [
        ("Bullet List", "l", 0.2, .data, "Convert the text below into a concise bullet list."),
        ("Numbered Steps", "n", 0.2, .data, "Convert the text below into clear, numbered step-by-step instructions."),
        ("Markdown Table", "t", 0.2, .data, "Convert the data below into a well-formatted Markdown table with sensible column headers."),
        ("Convert to CSV", "c", 0.1, .data, "Convert the data below into CSV with a header row. Quote fields that contain commas, quotes or line breaks."),
        ("Convert to JSON", "j", 0.1, .data, "Convert the data below into valid, well-structured JSON with sensible key names."),
        ("JSON to YAML", "y", 0.1, .data, "Convert the JSON below into equivalent YAML."),
        ("YAML to JSON", "a", 0.1, .data, "Convert the YAML below into equivalent, pretty-printed JSON."),
        ("Fix & Format JSON", "f", 0.1, .data, "Fix any syntax errors in the JSON below (missing quotes, trailing commas, comments and so on) and pretty-print it with 2-space indentation."),
        ("Extract Contacts", "e", 0.1, .data, "Extract all names, email addresses, phone numbers and postal addresses from the text below, one contact per line."),
        ("Extract Dates & Deadlines", "d", 0.1, .data, "Extract every date, time and deadline from the text below as a list in the form 'YYYY-MM-DD HH:MM — what it is', leaving out parts that aren't stated."),
        ("Extract Links", "u", 0.0, .data, "Extract every URL from the text below, one per line, without duplicates."),
        ("Sort Lines", "s", 0.0, .data, "Sort the lines of the text below alphabetically, ignoring case. Keep each line unchanged."),
        ("Remove Duplicate Lines", "r", 0.0, .data, "Remove duplicate lines from the text below, keeping the first occurrence of each and the original order."),
        ("Title Case", "i", 0.0, .data, "Convert the text below to Title Case following standard English capitalisation rules."),
        ("Calendar Event (.ics)", "q", 0.1, .data, "Create an iCalendar (.ics) file for the event described below with BEGIN:VCALENDAR, VERSION, PRODID and one VEVENT containing UID, DTSTAMP, DTSTART, DTEND (one hour after the start if not stated), SUMMARY, LOCATION and DESCRIPTION."),
        ("Clean Up Pasted Text", "w", 0.0, .data, "Clean up the text below: fix broken line breaks and hyphenation from copying, collapse extra spaces and blank lines, and normalise quotes and dashes. Do not change any words."),
        ("Key–Value Fields", "v", 0.1, .data, "Extract the structured information in the text below as 'Field: value' lines (for example name, date, amount, reference number), using the most natural field names."),
        ("Convert Units", "m", 0.1, .data, "Convert every measurement in the text below to metric units, or to US units if they are already metric, keeping the rest of the text unchanged and rounding sensibly."),
        ("Describe the Data", "p", 0.3, .answer, "Describe the table or data below in clear prose, highlighting the most important figures, trends and outliers."),
        ("Generate Sample Data", "g", 0.7, .data, "Generate 10 more realistic rows of sample data that follow the same format, fields and style as the example below."),
    ])

    static let learn = templates(.learn, [
        ("Explain Simply", "e", 0.4, .answer, "Explain the text below in simple terms a non-expert can understand, with one short example."),
        ("Explain Like I'm 5", "5", 0.6, .answer, "Explain the text below as if to a five-year-old, using a simple, friendly analogy."),
        ("Deep Dive", "d", 0.5, .answer, "Give an in-depth explanation of the topic below: core concepts, how it works, why it matters, common pitfalls and what to learn next."),
        ("Glossary", "g", 0.2, .answer, "Create a glossary of the technical terms, acronyms and jargon in the text below, each with a one-sentence plain-language definition."),
        ("Give Examples", "x", 0.7, .answer, "Give 3 concrete, varied real-world examples that illustrate the concept below."),
        ("Analogy", "a", 0.8, .answer, "Explain the concept below with a memorable everyday analogy, then note where the analogy breaks down."),
        ("Quiz Me", "q", 0.5, .answer, "Write 5 multiple-choice questions (A–D) that test understanding of the text below, with the answers and brief explanations at the end."),
        ("Flashcards", "f", 0.3, .data, "Turn the text below into flashcards, one fact or concept per card, in the form 'Q: … / A: …', one card per line."),
        ("Study Notes", "n", 0.3, .answer, "Turn the text below into concise study notes with headings, key points, definitions and a short summary at the end."),
        ("Mnemonic", "m", 0.9, .answer, "Create a memorable mnemonic, acronym or rhyme to help remember the key items in the text below, and show how it maps to them."),
        ("Solve Step by Step", "s", 0.1, .answer, "Solve the problem below step by step, showing the reasoning clearly, and state the final answer at the end."),
        ("Check My Work", "c", 0.2, .answer, "Check the answer or solution below for errors. Point out each mistake, explain why it's wrong and show the correct working."),
        ("Socratic Tutor", "t", 0.5, .answer, "Act as a Socratic tutor for the topic below: instead of giving the answer, ask 3 to 5 guiding questions that help me work it out myself."),
        ("Background & Context", "b", 0.4, .answer, "Provide the background needed to understand the text below: relevant history, key people or concepts, and why it matters."),
        ("Common Misconceptions", "i", 0.4, .answer, "List common misconceptions about the topic below and explain what is actually true for each."),
        ("Compare Concepts", "v", 0.3, .answer, "Explain the difference between the concepts mentioned below, with a comparison table and an example of each."),
        ("Key Concepts", "k", 0.3, .answer, "List the key concepts someone must understand to master the topic below, in the order they should be learned."),
        ("Learning Plan", "l", 0.5, .answer, "Create a 4-week learning plan for the topic below with weekly goals, practice exercises and the kinds of resources to use."),
        ("Explain a Reference", "r", 0.4, .answer, "Explain the meaning, origin and typical use of the idiom, quote, meme or cultural reference below."),
        ("Discussion Questions", "h", 0.6, .answer, "Write 5 open-ended discussion questions about the text below that encourage critical thinking."),
    ])

    static let language = templates(.language, [
        translation("English", "e"),
        translation("Spanish", "s"),
        translation("French", "f"),
        translation("German", "g"),
        translation("Italian", "i"),
        translation("Portuguese", "p"),
        translation("Dutch", "d"),
        translation("Russian", "r"),
        translation("Japanese", "j"),
        translation("Simplified Chinese", "c"),
        translation("Korean", "k"),
        translation("Arabic", "a"),
        ("Detect Language", "l", 0.1, .answer, "Identify the language of the text below, then translate it into English. Start with 'Language: …' on its own line."),
        ("Sound Native", "v", 0.4, .replace, "Rewrite the text below so it sounds like a fluent native speaker wrote it, fixing awkward or unidiomatic phrasing. Keep the same language."),
        ("Explain Grammar", "x", 0.3, .answer, "Explain the grammar of the sentences below in simple terms: their structure, verb tenses and any tricky constructions."),
        ("To British English", "b", 0.1, .replace, "Convert the text below to British English spelling, vocabulary and punctuation."),
        ("To American English", "u", 0.1, .replace, "Convert the text below to American English spelling, vocabulary and punctuation."),
        ("Pronunciation Guide", "o", 0.2, .answer, "Give a simple pronunciation guide for the words or phrases below, using an easy English respelling and IPA."),
        ("Explain Idioms & Slang", "q", 0.3, .answer, "Find the idioms, slang and figurative expressions in the text below and explain what each one means literally and in context."),
        ("Translate & Explain", "t", 0.3, .answer, "Translate the text below into English, then explain any cultural nuances, idioms or words that don't translate directly."),
    ])

    static let everyday = templates(.everyday, [
        ("To-Do List", "t", 0.3, .data, "Turn the brain dump below into a clean, prioritized to-do list using '- [ ] ' checkboxes, grouping related tasks."),
        ("Plan My Day", "p", 0.5, .answer, "Create a realistic time-blocked schedule from the tasks and commitments below, including breaks. Fit fixed appointments first and put demanding work in the morning unless told otherwise."),
        ("Shopping List", "s", 0.2, .data, "Turn the recipes or notes below into a shopping list grouped by store section (produce, dairy, pantry and so on), combining duplicate items and quantities."),
        ("Recipe Steps", "r", 0.3, .answer, "Rewrite the recipe below as an ingredient list followed by numbered steps, calling out times and temperatures and noting anything that can be done in parallel."),
        ("Meal Plan", "m", 0.7, .answer, "Create a 7-day meal plan from the preferences, ingredients or constraints below, with a combined shopping list at the end."),
        ("Trip Itinerary", "i", 0.7, .answer, "Create a day-by-day travel itinerary from the details below that balances activities, travel time and rest. Use [brackets] for anything not specified."),
        ("Packing List", "k", 0.4, .answer, "Create a packing checklist for the trip described below, grouped by category and tailored to the destination, length and activities."),
        ("Gift Ideas", "g", 0.9, .answer, "Suggest 10 thoughtful gift ideas for the person described below across a range of prices, each with a one-line reason."),
        ("Budget Breakdown", "b", 0.2, .answer, "Organize the expenses or figures below into a budget table by category with totals, and point out the biggest opportunities to save. Double-check the arithmetic."),
        ("Plain-English Terms", "l", 0.2, .answer, "Explain the contract, policy or terms below in plain English: what I'm agreeing to, obligations, costs, deadlines, cancellation terms and anything unusual or risky. Note that this is not legal advice."),
        ("Explain Medical Terms", "h", 0.2, .answer, "Explain the medical terms or report below in plain language and suggest questions I could ask my doctor. Note that this is not medical advice."),
        ("Help Me Decide", "d", 0.4, .answer, "Help me decide based on the situation below: list the options and key factors, the pros and cons of each, and give a recommendation with reasoning."),
        ("Brainstorm Ideas", "n", 1.0, .answer, "Brainstorm 15 diverse, creative ideas about the topic below, from safe to bold, one line each."),
        ("LinkedIn Post", "o", 0.7, .message, "Turn the notes below into an engaging LinkedIn post with a strong first line, short paragraphs, a concrete takeaway and at most 3 relevant hashtags."),
        ("Short Social Post", "x", 0.8, .message, "Write a short, punchy social media post of under 280 characters based on the text below."),
        ("Cover Letter", "c", 0.6, .message, "Write a concise, tailored cover letter from the job description and background below. Highlight the most relevant experience with concrete results and avoid clichés."),
        ("Résumé Bullets", "e", 0.4, .replace, "Rewrite the experience below as strong résumé bullet points that start with action verbs and quantify impact where the text gives numbers. Do not invent metrics."),
        ("Short Bio", "a", 0.6, .replace, "Write a short professional bio of about 80 words, in the third person, from the details below."),
        ("Card Message", "y", 0.8, .message, "Write a heartfelt card message for the occasion described below (birthday, wedding, farewell, sympathy and so on), matching the relationship and tone given."),
        ("Product Review", "v", 0.6, .answer, "Turn the notes below into a helpful, balanced review with a rating out of 5, pros, cons and who it's best for."),
    ])
}
