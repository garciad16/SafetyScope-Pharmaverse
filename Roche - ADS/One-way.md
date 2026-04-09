**Text Q1: "What excites you about this opportunity with Roche/Genentech, and how do you see yourself contributing to the mission of PD Data Sciences & Analytics (PDD)?"**

"What excites me is that this role is about building the datasets and programming outputs that directly feed early development decisions. I've been doing similar work at UHN for the past three and a half years — writing complex data queries against EPIC, building data quality pipelines in Python, and creating analysis-ready datasets that support clinical trial eligibility screening across 50+ oncology trials. The difference is I've been doing it on the hospital side, and this role lets me do it on the pharma side where those outputs inform go/no-go decisions on experimental therapies.

In terms of contributing to PDD's mission — I bring strong programming skills in R and Python, hands-on experience with clinical data structures, and a data quality mindset built from working in an environment where accuracy directly affects patient care. I've standardized over 1200 diagnosis-to-drug mappings using NCI and AJCC standards, built automated validation frameworks, and recently started building an R Shiny dashboard using pharmaverse packages and ADaM datasets for early-phase clinical trial safety review. I understand what it means to produce outputs that are traceable, reproducible, and fit for purpose — which is exactly what this role requires.

I'm also genuinely excited about working with exploratory and non-standard data like biomarkers and genomics. That's what I do now at UHN with cBioPortal genomic data and clinical trial eligibility criteria. Moving into early development programming at Roche would let me apply that experience in a more structured regulatory environment while deepening my skills in areas like ADaM standards and statistical programming."

---

**Text Q2: On-site 3 days per week in Mississauga**

"Yes, I'm based in Toronto and can meet the onsite requirement at the Mississauga campus with no issues. No relocation needed."

---

**Text Q3: Salary expectations**

Given the posted range is $89,256 - $117,148, aim for the middle:

"Based on my experience with clinical data programming and analytics in a healthcare research environment, I'd be looking in the range of $95,000–$105,000. I'm open to discussing compensation as part of the full package."

---

## VIDEO QUESTIONS

---

**Video Q1: "Tell us about a time you built or adapted a data visualization that helped a team make an important study decision. What impact did your work have?"**

"The best example is the R Shiny dashboard I built for PMATCH, our clinical trial matching system at UHN. The system runs nightly — it takes patient data like genomic alterations, cancer staging, and drug history, matches them against 50+ active trial eligibility criteria, and produces match results.

Before the dashboard, the team had no centralized way to see what was happening. How many patients matched, which clinicians those patients belonged to, what eligibility criteria each patient met, whether clinicians were actually reviewing their matches — all of that was scattered. I built the dashboard to surface it all in one place. Match volumes on a nightly basis, clinician review status, pending reviews, and the specific criteria behind each match so the clinical team could see exactly why a patient was flagged.

The impact was direct. Because we could track clinician activity and see who had pending reviews sitting there, we could follow up and make sure matches weren't going unreviewed. That visibility directly contributed to us recently having our first patient marked as eligible by a clinician through the system — that's one of the first successful end-to-end outcomes for UHN's CDI team, going from data pipeline all the way to an actual clinical decision.

I also have experience from HWisel where I built real-time monitoring dashboards for IoT devices in condo buildings — tracking water levels in pipes to catch overflows, monitoring oven temperatures to flag malfunctions. Different context, but the same idea — taking live data and presenting it so someone can see what needs attention and act on it."

---

**Video Q2: "Tell us about a time when you worked with complex data. How did you ensure your programming outputs were both accurate and reproducible?"**

"My entire role at UHN is built around this. The PMATCH system takes patient data from multiple sources — EPIC clinical extracts, genomic data from cBioPortal, drug histories — and maps them against clinical trial eligibility criteria. The data is complex because each source uses different formats and different coding systems, and there are inconsistencies that need to be handled before you can match anything reliably.

For accuracy, I built automated validation checks at every step. For drug classification, I built a module in Python that takes drug names from patient records, searches the NCI Thesaurus API, resolves synonyms, and maps them to the right drug class. Anything that doesn't resolve cleanly gets flagged for manual review instead of being silently dropped or misclassified. For genomic data, I built comparison tools that check our mapped outputs against the source data in cBioPortal. For completeness, I have checks that catch missing staging information or incomplete biomarker data before it ever reaches the matching step. Across the board, the framework achieves over 99% accuracy.

For reproducibility, everything is rule-based and documented. Every match can be traced back to the source data and the specific logic that produced it. I standardized over 1200 diagnosis-to-drug mappings using NCI and AJCC standards so the same input always produces the same output. If someone asks why a patient was matched to a trial, there's a clear answer — you can follow the chain from raw data to final result. I also use Git for version control, so when logic gets updated, previous versions are preserved and you can see exactly what changed and when.

More recently, I've been applying those same principles to my SafetyScope project, which is an R Shiny dashboard built on pharmaverse packages using ADaM datasets — ADSL, ADAE, ADEX, ADLB. Working with ADaM structures has reinforced how important standardized data formats are for reproducibility, because when everyone follows the same structure, the downstream programming and validation becomes much more reliable."

---

**Video Q3: "Tell us about a time you learned a new tool or standard quickly to meet a study deadline. How did you get up to speed, and what did you deliver?"**

"A good example is when I needed to build the drug classification module for PMATCH. Our system could only match patients on basic drug information — whether they'd had chemotherapy or immunotherapy. But clinical trial protocols are much more specific. They'll say something like 'patient cannot have received a PD1 inhibitor,' and we had no way to check that because we couldn't connect drug classes to the specific drugs in a patient's treatment history.

I needed to learn the NCI Thesaurus API from scratch. It's a hierarchical system — so PD1 inhibitor sits at one level, and underneath it are all the specific drugs like Pembrolizumab, Nivolumab, and so on. Each drug can also have multiple synonyms. On one side we had trial eligibility criteria saying 'no PD1 inhibitors,' and on the other side we had patient treatment records with specific drug names. My module needed to connect those two.

I started with the API documentation and their GitHub SDK, but the docs only get you so far. What actually worked was picking a known example — PD1 inhibitors — running queries, seeing what came back, and testing against cases I already knew the answer to. When I hit edge cases like combination therapies or drugs with unusual names, I'd adjust and test again.

What I delivered was a drug classification module that could take any drug class from a trial's eligibility criteria, look up every drug that falls under it through the NCI hierarchy, pull in all the synonyms, and compare that against what a patient had actually received. Before this, we were missing matches because we couldn't connect drug classes to specific drugs. After, that whole category of matching was covered.

The approach I'd bring to Roche is the same — start with the documentation, get hands-on fast, test against real examples, and iterate until it works on the messy real-world cases, not just the clean ones."

---

**Video Q4: "What interests you about working in real-time visual analytics for early development clinical trials?"**

"Two things. First, early development is where the stakes are highest. These are first-in-human and proof-of-concept trials — you're testing something in patients for the first time. The datasets and visualizations at that stage aren't just reports, they're what study teams use to make safety decisions and figure out whether a therapy is worth moving forward. I want my programming work to be close to that kind of impact.

Second, I've worked on both sides of what this role needs. At HWisel I spent two years building real-time monitoring dashboards — data coming in continuously, and the visualizations had to update and surface problems immediately. At UHN, I've been on the data side — building pipelines, validation logic, and analysis-ready datasets for clinical trial matching. This role brings both together — building the datasets and the visual outputs that support early development decisions.

What also draws me in is the exploratory nature of early development work. The job description mentions non-standard endpoints, biomarkers, and flexible data design. That's familiar territory for me — at UHN I work with genomic data, non-standard cancer coding systems, and trial eligibility criteria that vary widely from protocol to protocol. I'm used to dealing with data that doesn't fit neatly into a template and figuring out how to structure it so it's useful.

I've also recently been working on SafetyScope, which is an R Shiny dashboard I built using pharmaverse packages and synthetic ADaM datasets for early-phase safety review — adverse event analytics, treatment exposure plots, demographic summaries. Building that project showed me how much I enjoy this specific type of work, and it made me want to do it for real studies with real patient data."

---

**Video Q5: "Visual analytics in clinical trials is evolving rapidly. What excites you most about the future of this field, and how would you like to contribute?"**

"What excites me most is the move from reviewing data after the fact to watching it as it comes in. I've seen that shift firsthand at UHN. Our trial matching system runs nightly, and before I built the dashboard, the team had to manually ask around to figure out where things stood — how many patients matched, who's reviewed what, what's still pending. Now they just open the dashboard and it's all there. That one change made the team way more efficient.

From what I've read about where this field is going, AI is starting to play a bigger role — not replacing the dashboards, but making them smarter. Things like automatically flagging patterns in safety data that a human might miss, or catching something unusual in a patient's results before it becomes a bigger problem. The dashboard goes from just showing you the data to actually pointing you toward what needs attention. I think that's really exciting because it means the person building the datasets and visual outputs has a direct impact on whether a safety issue gets caught early or gets missed.

In terms of how I'd contribute — I want to start by learning the basics well. Learn Roche's programming conventions, understand how early development datasets are structured, get comfortable with ADaM standards and the team's validated tools. Then over time, as I understand the workflows better, I'd want to start suggesting improvements — better ways to structure exploratory datasets, more effective visualizations for non-standard endpoints, or programming workflows that make outputs more reproducible. At UHN I learned that the best ideas come from watching how people actually use the tools and then adjusting the design around that."