
Q1: "What excites you about this opportunity with Roche/Genentech, and how do you see yourself contributing to the mission of PD Data Sciences & Analytics (PDD)?"**

I've been wanting to transition from hospital-side analytics into pharmaceutical drug development ever since I started working on PMATCH which is a clinical trial matching system where I work with patient genomic data, treatment history, drug classifications, and eligibility criteria. That work gave me a real interest in the clinical trial lifecycle, and especially what happens on the early development side where the data and analysis directly shapes whether a development moves forward.

What excites me about this role specifically is that it's focused on building analysis-ready datasets and programming outputs for early-phase studies and that matches how I worked with PMATCH. At UHN I deal with data that doesn't always fit into a template like genomic data, various data standards, eligibility criteria, drug classification, etc... I'm used to figuring out how to structure messy data so it's usable for decision-making.

I see PDD as the right environment to develop my skills in a structured regulatory setting while learning from experienced programmers and statisticians. I bring hands-on experience with R, Python, clinical data pipelines, data validation, and recently I've been working with ADaM datasets through pharmaverse to build a safety review dashboard. I'm ready to apply that foundation to real early-phase studies and grow from there."


Q2. Tell us about a time you used automation or AI tools to improve your programming workflow. What motivated you to try it, and what impact did it have?

A good example is when I noticed clinicians on the PMATCH team were manually going through their matched patients trying to figure out which ones were the most significant, basically which patients had the most trial criteria eligibility that were met, the trial arms and number of trials they appeared in. It was sorted so that most significant patients were at the top. At first I had the output in a CSV that I'd send clinicians so that they could see their ranked patients but eventually that became part of the R Shiny dashboard I was building, so rather handing them a CSV, they could just open the dashboard and see it

I tend to think in terms of what can be automated. So when I see someone doing things manually, it motivated to take initiative and see the type of automating tools possible to make it happen

AI tools like LLMs help me understand new concepts and organize my thinking around complex workflows, especially learning clinical data standards that are completely new to me. I find them useful for getting up to speed and understanding the scope before diving in

On a broader level, I've automated a lot of the data validation work for PMATCH using Python to flag incomplete records, missing staging data, mapping drug names instead of doing manual work



Q3. "Give an example of a time you had to make tradeoffs between speed and quality in a programming deliverable. How did you decide what to prioritize, and what was the result?"

To add on from my previous example, I was building the patient ranking logic for PMATCH where clinicians needed a way to see which of their matched patients were most significant. The problem was that they were doing this manually

The full solution I had in mind was building this into the R Shiny dashboard with date range filtering and interactive sorting. But that would take time so instead I started by running a manual query for a single day, building the mapping logic to confirm the joins between patient data and trial eligibility and finally outputting those results to a CSV for clinicians to see

That quick approach let me do a few things. It validates that the fields, find the key relationships before the full extraction, got feedback from clinicians on whether the ranking logic made sense, and find gaps early instead of discovering them after doing the whole scope

Once the logic was confirmed, I automated it across a full date range and built into the R Shiny dashboard in which the clinicians can just open and see the results

The way I think about it is that we first get something functional, make sure the logic is right, then invest the time in building a proper clean solution.


Q4. "Describe a situation where you took full ownership of a coding or data issue. How did you ensure it was resolved and didn't happen again?"

Early in my work with PMATCH, I was tracking data completeness across our research cohorts, OCTANE, BIOCAN, HOPE, and others. I needed to know which fields existed for each patient in each cohort, because those fields are what we use for trial eligibility matching. Things like clinical, diagnosis, biomarkers, staging, treatment history.

I built my completeness analysis assuming all cohorts followed the same data standard. Then when I shared my findings with a colleague, some fields in certain cohorts were showing 100% missing. That wasn't good, so we reached out to a clinician who mange the cohort's data. They checked their raw data and confirmed those fields were actually populated. So the data existed but my analysis wasn't picking it up

What I realized was that not all cohorts follow the same data standard. Most were using cbioportal's standard, but one or two used a different healthcare standard entirely. So the fields I was looking for existed in those cohorts but under different names.

So that was on me as I made an assumption about the data without verifying it. I went back, mapped out which standards each cohort used, built the linkage between different field names and update the completeness analysis to account for those differences. Going forward, whenever we onboard a new data source, the first step is always to check its data fields and what standard it follows and map it to our own schema before running any analysis on it

I also learnt that healthcare data is messy. It made me understand why standards like FHIR and CDISC exist. I find that each institution has there own language of defining there data so everyone names the fields and structure differently so you can't assume all the data lines up.


Q5. "Tell us about a project where you created or contributed to a dashboard or interactive data visualization. What tools did you use, and how did you make sure it met the needs of end users?"

The most relevant dashboard experience I have is the most recent one with building an R Shiny dashboard for PMATCH at UHN. The tool tracks clinical trial matching, it shows nightly match volumes, the list of patients that each clinician has, what eligibility criteria each patient met, pending reviews and clinician usage over time. I built it in R using Shiny and tidyverse for the data processing.

When I built the dashboard, my focus was on making sure the logic was right and the functionality was there, that the data was accurate, the matching metrics were correct, validating, making sure results were reproducible and lastly making sure everything was pulling from the right sources. 

Once the core functionality was good, I showed it to the clinical team to get their feedback. I kept the results direct and simple as requested, organized by patient, by clinician, filtering by a date range, trial arms, etc. That made it easy to use for non-technical users and it directly contributed to us getting our first patient marker eligible through the system

My earlier visualization experience was HWisel where I spent the first two professional career working on building real-time IoT monitoring dashboard. Which tracked things like water levels in pipes for catching overflows, oven temperature monitoring, and flagging malfunctions in condo buildings. The came in as JSON through a cloud platform which I'd parse and build the dashboard interface for users to see and monitor

I've also recently started building a personal project using R pharmaverse packages which comes from Genentech. I'm working with synthetic ADaM datasets like ADSL, ADAE, ADEX, and ADLB to build a safety review dashboard covering demographics, adverse events, and treatment exposure. Moving into early development drug safety is where I want to transition to, so I wanted to get hands-on with the data standards and tools this team actually works with.



Q6. "Give an example of how you taught yourself a new programming tool, dataset standard, or process. Why did you pursue it, and how did it help you in your role?"

I'll give two examples where I found a gap in our system

The first was a diagnosis mapping problem. We needed to map free-text diagnoses from our database to standardized OncoTree codes. The existing approach used ICD-O-3 codes and histology data to get the specific cancer site for the mapping. The problem was, only a small portion of our diagnoses had coverage

I brought in the idea of using machine learning to solve it. We had a lot of free text diagnoses and wanted to take advantage of that. So I explored tools and I decided to use PubMedBERT, a model trained on medical literature to convert both the free text diagnoses and oncotree name into vectors. Then I used cosine similarity to compare the two texts based on the cosine angles to map to OncoTree code. We went from about 15% coverage to about 50% which was a big jump.

The second example was the NCI Thesaurus API for drug classification. We had no way to connect drug classes in our patient match values. For example, patient cannot have PD1 inhibitor to be eligible to a trial but a patient has taken a list drugs (for example pembrolizumab, nivolumab) and so we needed to find out if those drugs are related to PD1 inhibitor. I found the API for the NCI thesaurus and pulled endpoints and built a script to take all the necessary data to fill the missing gaps for our drug matching criteria.

In both cases, I took the initiative to do the research, find the correct tools and learn them. Once I see a gap that needs solving, I check if we have the necessary tools to solve those gaps if not then we can explore new tools to solve that problem.