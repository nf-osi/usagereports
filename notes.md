### Notes

This is a document outlining what we might wish to answer in a usage report, written in the form of funder user stories.
Given **data from the platform**, questions range from being easily answerable to not answerable at all.
Important but less feasible questions should be documented here in case future changes make them more tractable. 
These questions might also lead to suggestions for what/how other data should be better collected. 

### Rubric
Importance:
- ⭐⭐⭐ / High 
- ⭐⭐ / Medium
- ⭐ / Low

Feasibility
- 🟢 / Doable with platform data
- 🟡 / Inconveniently to painfully doable with platform data
- 🔴 / Not doable with platform data

#### Implementation Matrix
This matrix tries to summarize which questions will be pursued and included in the report according to `Importance` and `Feasibility`.

|       | 🟢  | 🟡  | 🔴 |
| ------| --  | -- | -- |
| ⭐⭐⭐ | yes | yes | no  |
| ⭐⭐   | yes |  ?  | no  |
| ⭐     | ?  | no  | no  |

---

### As a funder, I would like to know...

#### How many studies changed status from "Under Embargo" to "Partially Available"/"Available" between the beginning to the end of the year (or whatever the report period may be). ⭐⭐⭐ | 🟢 
- This would 1) give indication that data is being released on time and 2) help set up expectations for what downloads might look like based on releases.

#### How long does it take for others to use the data once there is data released (for those projects that do see use). ⭐⭐ | 🟡  
- Help understand the range of timelines on "returns" -- do researchers make use of data within a month, several months, a year, several years of release? 
- Date of first download - Date status change.
- "Data release" dates are not officially (and sometimes not accurately) tracked, and would have to query all weekly snapshots of the study table to get approximate transition. 
- Suggests that "data release" should be tracked in a more principled manner especially if this is an important question to be pursued. 

#### Which of the projects in my portfolio have seen the most usage in terms of absolute downloads? ⭐⭐⭐ | 🟢 
- Top 20% of projects with the most impact/interest.

#### What proportion of projects in my portfolio have seen any usage (Team A projects) vs. not (Team B projects)? ⭐⭐⭐ | 🟢 
- Example: 40% use vs. 60% no use.

#### Are there any differences in Team A projects vs Team B projects? ⭐⭐ | 🟡 
- Size of project (total number of files)?
- Age? (Since it takes time to be aware of projects.)

#### What is the summary of usage in terms of absolute file downloads? In terms of unique platform users? ⭐⭐⭐ | 🟢

#### What is the summary of usage in terms of secondary citations? ⭐⭐⭐ | 🔴 
- This requires curation *outside* of the platform. Some platforms such as dbGaP can require that any publications using the data must be documented, in which case this information becomes part of the platform.

#### What has been the trend in pageviews/downloads over *this* report period? ⭐⭐⭐ | 🟢

#### What has been the trend in pageviews/downloads compared to the *last* report period? ⭐⭐⭐ | 🟢
- Note: not available for first report.

#### Per project, what is the total number of unique users who have downloaded data? ⭐⭐⭐ | 🟡
- The concept of a "download" needs to be refined in the backend as it currently includes any time a pre-signed url is created (e.g. file previews, table downloads (maybe we want this?), actual downloads...)

#### What is the total number of unique users who have downloaded data? ⭐⭐⭐ | 🟡
- Note: only relevant after the first data release.

#### What is the data type breakdown of data being used? ⭐⭐⭐ | 🟢

#### What is the assay breakdown of data being used? ⭐⭐⭐ | 🟢

#### How do data users learn about the data -- directly through the portal, the publication, newsletter/social media, word-of-mouth, something else? ⭐⭐ | 🔴 

#### How is the data used -- e.g. for NF-specific research, NF-related, or NF-unrelated? ⭐⭐⭐ | 🟡
- Relevant only for funders that allow relatively open use -- i.e. for GFF it *must* already be NF-specific research.
- This would *only* be available for data that requires a data use statement, and would need manual review to categorize the usage.

#### What is the demographics of my data users? ⭐⭐ | 🔴
- Grad students, post-docs, PIs, academic, industry? Where are they from, geographically?
- This may be painfully answerable if there are only a handful of complete profiles to manually review, but the platform needs to require this information as part of the standard profile for this to be truly feasible.
- Since platform data is lacking, another method is more _indirectly_ though surveys. 

#### Are the data users linked to the same NF funding agency, another NF funding agency, another group on Synapse, or independent? ⭐ | 🟡
- Measures potential connections with other groups.  
- Requires defining what "linked to" really means, particularly within NF funding agencies (many PIs are funded by more than one of our partner-funders). 

#### How does my reach compare with other funding agencies (e.g. NTAP  vs CTF)? ⭐⭐ | 🟢
- Data are on same platform and should be pretty much comparable.
- Account for different number of projects/types of projects. 
- Compare projects unique to the funding agency (i.e. ignore projects with collaborative funding).

#### What correlates with data use? The funding amount of the project, quantity of data available (which should already depend on the funding), numbers of reads for the related publication, type of data, extent of social media engagement, etc.? (Similar to but larger in scope compared to one of the above.) ⭐⭐⭐ | 🔴
- Most of this data is outside the scope/a big effort to get.


