## ABOUT YOU (new ones)

---

**"Tell us about a time you worked with someone from a different background or discipline."**

"That's basically every day at UHN. I'm a computer science guy sitting on a cancer informatics team with oncologists, clinical trial coordinators, and research staff. The way we think about data is completely different. I think in terms of data structures and logic. They think in terms of patients and clinical workflows.

A good example — when I was building the drug classification module, I needed to understand how clinicians actually think about drug categories. To me, a PD1 inhibitor was just a node in the NCI Thesaurus hierarchy. To the clinician, it's a treatment decision with specific side effects and implications for what trials a patient can enter next. Having those conversations helped me build better logic because I understood what the categories actually meant clinically, not just how they were organized in a database.

I think working across disciplines is something I'm comfortable with at this point. You just have to accept that the other person knows things you don't, ask questions without pretending you already know the answer, and be open to changing your approach based on what they tell you."

---

**"Give an example of a time you had to prioritize competing tasks."**

"At UHN I'm often working on multiple pieces of PMATCH at the same time — data pipeline updates, validation fixes, dashboard improvements, and sometimes ad hoc requests from the clinical team who need something pulled quickly.

One situation that comes to mind is when I was in the middle of building out the drug classification module and a request came in to run a data completeness analysis for a set of patients that were being reviewed that week. The drug classification work was important long-term, but the completeness analysis had a hard deadline because clinicians were making decisions on those patients.

I paused the drug classification work, got the completeness analysis done and delivered, then went back to what I was working on. It wasn't complicated decision-making — I just asked which one has people waiting on it right now. If the answer is clear, you do that one first. If both are urgent, I'll check with my manager on what to prioritize rather than guessing."

---

**"Describe a time you went above and beyond what was expected."**

"The R Shiny dashboard for PMATCH wasn't something I was asked to build. My core job was the data pipelines and validation logic — making sure the matching system worked and the outputs were accurate. But I kept seeing the team struggle to answer basic questions like how many patients have been matched, who's reviewing them, what's still pending. That information existed in the data but nobody had an easy way to see it.

So I started building the dashboard on the side. I used what I was learning in R Shiny to put together a view that tracked match volumes, clinician review status, and pending actions. Once I showed it to the team and they started using it, it became a core part of how we operate. And it directly contributed to us getting our first patient marked eligible through the system.

I didn't wait to be told to build it. I saw a gap, knew I had enough skill to fill it, and just did it."

---

## WORK STYLE

---

**"How do you handle ambiguity or unclear requirements?"**

"Honestly, that's most of my job. PMATCH is a system that's still being built out — there wasn't a detailed spec sheet handed to me on day one. A lot of it was my manager explaining the vision — we want to match patients to trials using clinical data — and then me figuring out the specifics as I went.

When requirements are unclear, my approach is to build something small first and get feedback fast. I'll make my best interpretation of what's needed, put together a rough version, show it to whoever's going to use it, and ask if I'm on the right track. That's way more productive than sitting around waiting for perfect requirements, because in my experience those never come anyway.

If I'm genuinely stuck and don't even know where to start, I'll ask. I'd rather spend five minutes getting clarification than spend a day building the wrong thing."

---

**"How do you stay organized when managing multiple projects?"**

"Nothing fancy — I keep a running list of what I'm working on, what's blocked, and what's coming up next. At UHN I'm usually juggling pipeline work, validation updates, dashboard improvements, and ad hoc requests at the same time.

What helps me most is knowing which things have hard deadlines and which ones are ongoing. The hard deadline stuff gets done first. The ongoing work I'll chip away at between the urgent tasks. I also try to batch similar work together — if I'm already in the data pipeline code, I'll knock out a few related fixes while I'm in there instead of context switching back and forth.

The main thing is I check my list at the start of every day and adjust based on what's changed. It's not a complicated system but it keeps things from falling through the cracks."

---

**"What does good collaboration look like to you?"**

"For me it's pretty simple — everyone's honest about what they know and what they don't, and people actually listen to each other instead of just waiting for their turn to talk.

At UHN, the best collaboration I've had is with the clinical team on PMATCH. I know the data and the code. They know the patients and the clinical workflows. When we both bring our piece honestly and respect what the other person brings, the work gets better fast. The times it hasn't worked as well is when either side assumes they know the other's domain — like me assuming I know how clinicians review patients, or them assuming the data can do something it can't.

I think good collaboration also means being okay with changing your mind. Some of my best work came from a clinician telling me my approach didn't make sense from their perspective, and me going back and rebuilding it."

---

**"How do you approach a task you've never done before?"**

"I start by figuring out what I do know that's similar. When I joined UHN, I'd never worked with clinical oncology data, but I knew how to process and validate data. So the patterns were familiar even if the content was new.

From there I'll look at documentation, find examples of how other people have solved the same problem, and then just start building something. I learn way faster by doing than by reading. I'll build a rough version, test it, see what breaks, and iterate. If I'm stuck on something domain-specific — like when I didn't understand how cancer staging rules worked — I'll go ask someone who does.

The SafetyScope project I built recently is a good example. I'd never worked with ADaM datasets before. I started by reading about the data structure, pulled in synthetic data from the pharmaverse packages, and just started building tabs — demographics, adverse events, treatment exposure. Each tab taught me something new about how ADaM data is organized. By the end I had a working dashboard and a solid understanding of the data standard."

---

**"What kind of work environment do you thrive in?"**

"I do best when I have a mix of independent work and collaboration. I need focused time to actually build things — write code, work through data problems, test outputs. But I also need regular check-ins with the people who use what I build, because that's how I know whether I'm building the right thing.

At UHN, that balance works well. I'll spend a morning heads-down on pipeline or validation work, then sync with the clinical team in the afternoon to review outputs or get feedback. I don't need someone checking in on me every hour, but I also don't want to go weeks without feedback.

I also do well in environments where it's okay to ask questions and admit when you don't know something. At UHN, I've never been made to feel bad for not knowing a clinical concept — the team understands I come from a technical background and they're willing to explain. I'd want that same kind of culture at Roche, especially while I'm ramping up on new standards and workflows."