# local_reporting
Code and files related to the Local Reporting Dashboard

## About
This tool was developed to help prioritize counties/cities for a local reporting initiative. It incorporates 2020 data from the U.S. Census Bureau (for ZCTA level demographic projections, and 2019 county level estimates for Hispanic/Latino populations), UNC's Expanding Media Desert project, the Center for Community Media's Black Media Initiative, CUNY's Latino News Media Map, the Institute for Nonprofit News' Member Directory, the National Association of Black Journalists' Chapters page, the Gun Violence Archive, and Mapping Police Violence. 

This dashboard **does**: 
- Allow users to decide what variables are important to launching a data investigation
- Output a map (darker circles indicate higher ranking) with the top 100 ranked counties based on user input
- Output a table with the same top 100 ranked counties, their state, and their division, along with relevant data on gun violence, police violence, local newspapers, local nonprofit partners, Black/Latino media groups, Black population, the county's rank within its division, and the county's rank overall.
- Allow users to download a csv of the data within the table to help guide decisions on local investigations and on-the-ground reporting

This dashboard **doesn't**:
- Account for funding opportunities, ability to recruit talent, or qualitative data on the quality of crime coverage in a given region
- Account for the Latino community at the city level due to insufficient data.
- Update automatically as new data becomes available :(

## Data Sources
In its current form, this data is updated manually. I link to each data source below and outline potential opportunities to automate data pulls, where applicable below:

[U.S. Census Bureau ZCTA level demographic projections](https://data.census.gov/cedsci/table?t=Race%20and%20Ethnicity&g=0100000US.860000&tid=ACSDT5Y2019.B02001&hidePreview=true): There are [APIs](https://api.census.gov/data/key_signup.html) available for pulling this data. I haven't looked into how frequently projections are updated, but my gut tells me that it's <= once a year. I also obtained county level data on Hispanic/Latino populations here.

[UNC's Expanding Media Desert Project](https://www.usnewsdeserts.com/reports/news-deserts-and-ghost-newspapers-will-local-news-survive/): I had to personally request access to UNC's Media Desert data, and it's unclear how often this is refreshed. They emailed me a single XLSX file that includes newspapers in 2004, 2014, 2016, and 2020, along with newspaper closures from 2004-2019 (according to tab names). 

[Center for Community Media's Black Media Initiative](https://airtable.com/shrKbdiGOaRdsSIIW/tblPDC9g46NM1n7Np): This is an Airtable view put together by [CUNY's Mapping Black Media](https://www.journalism.cuny.edu/2020/11/mapping-black-media/) project. I've used R's airtabler package to pull from Airtables that I have 'Creator' permissions on, but haven't tested it for publicly available views. In theory, this should be automatable.

[CUNY's Latino News Media Map](http://thelatinomediareport.journalism.cuny.edu/latino-media-report/): This data is available in a [Google sheet](https://docs.google.com/spreadsheets/d/1tJBBdteHEpqTBYco9Gn9HOOshQselWJLK97MLN3SWFU/edit#gid=1512912659), which according to the title was last updated April 2019.

[Institute for Nonprofit News Member Directory](https://inn.org/members/): I did some very basic web scraping to get Name, City, and State of each INN member, although this website is a little wonky in that there are multiple places to access a directory, but different organizations in the directory depending on which way you access it. One of them contains many more members than the other (they're publicly at ~250 members according to their [2020 report](https://1l9nh32zekco14afdq2plfsw-wpengine.netdna-ssl.com/wp-content/uploads/2020/06/INN.2020.FINA_.06.15.20.pdf)), and there are some instances where a non-profit newsroom clearly changed their name since they joined as a member. I wish I'd taken better notes so that I could give you a specific example here, but I would Google a newsroom's name to double check its location and it would be under a different name in the Google search. 

[National Association of Black Journalists' Chapters](https://www.nabj.org/page/RegionMap): I did some very basic web scraping here to get National Association of Black Journalist (NABJ) chapter names, city, and state by cycling through each region at the URL above. For the sake of this project, I'm counting both professional and student chapters, since there is a history of working with youth journalists. I can adapt this to exclude student chapters, since youth journalist partnerships tend to be the exception, not the norm.

[Gun Violence Archive](https://www.gunviolencearchive.org/query): The Gun Violence archive documents gun violence incidents across the United States, creates reports, and helpfully lets you download data, but not more than 2,000 records, and it won't tell you on its website that that's the limit. >:( I tried to scrape this data, and it still didn't let me access more than 2,000 records. Anyway, I manually compiled this data to get all the gun violence incidents from 1-1-2020 to 12-31-2020. I asked Daniel whether he's been able to get a data stream for Atlas of American Gun Violence, and he said he has not. He did helpfully send over the data that GVA compiled for him, so in the future I can get this from him if we want more than one year of gun violence data in this tool.

[Mapping Police Violence](https://mappingpoliceviolence.org/aboutthedata): Mapping Police Violence is a research collaborative that documents incidents of police killings nationwide from 2013 - present. While it is extremely difficult to assess the full scale of police violence, this offers a proxy. Their data, pulled mainly from three other databases, is surprisingly robust and includes data on zipcode, victim gender/age/race/name/cause of death, along with several metrics that I believe are reported by the police, including whether the victim displayed signs of mental illness, was armed/unarmed, threat level, fleeing/not fleeing, encounter type, and initial reported reason for violence. A lot could be done with this data, but for the sake of this dashboard, I simplified it to just number of police-caused deaths by zipcode/city/state. 

**Overall Notes**
Over the course of joining data together, I found instances where a zip code had been entered incorrectly into one of the data sources, or a city had been misspelled, or a state abbreviation was incorrect. In these events, I manually corrected them. In retrospect, it would have been [cool](https://www.healthline.com/health/am-i-a-bad-person) of me to notify the organizations in charge of these data sources to help them update their data so that other people could avoid that work, but I got too excited about moving on to the next step of the project. 

## Dashboard Functionality
#### Sliders
The sliders in the dashboard are used to weight variables to guide a decision on where to center data investigations and/or place on-the-ground reporters. Sliding to the left means the variable is less important to that decision; sliding to the right means you feel the data is more important. The sliders are as follows:

- **2020 Gun Violence** (number of people killed or injured by guns in 2020. If the same person was shot twice in 2020 on separate days, that would count as two incidents)
- **Police Violence** (number of killings by police from 2013-2020, per designated geography)
- **Local News Outlets Per Capita** (number of local news outlets in a designated geography/designated geography population, to help evaluate the need for better gun violence reporting)
- **INN Members** (number of INN Members per designated geography, to evaluate potential non-profit partnership opportunities)
- **Black and/or Latino Media Presence** (number of Black Media Groups + number of Latino Media Groups + number of NABJ chapters, to evaluate potential partnership opportunities with Black and/or Latino journalists)
- **Black Community** (Black population/designated geography population, according to ACS projections, because gun violence is an issue that disproportionately impacts Black and Latino people and our work should represent and serve them.)
- **Latino Community** (Latino population/county population, according to ACS projections. Hispanic/Latino data seems to only be available at the county level and higher, unfortunately)

The sliders operate to weight a city's final ranking. The input dataset has already assigned a rank to each city based on each variable in question. The slider setting determines the weighting. The final ranking of cities is equal to:

(2020 Gun Violence Rank x Gun Violence Slider Weight) + (Police Violence Rank x Police Violence Slider Weight) + (Local News Outlets Per Capita Rank) x Local News Slider Weight) + (INN Members Rank x INN Members Slider Weight) + (Black and/or Latino Media Presence Rank x Black and/or Latino Media Presence Rank) + (Black Community Rank x Black Community Weight) + (Latino Community Rank x Latino Community Weight)

Therefore, pulling the slider all the way to 0 indicates "This variable is not important at all to prioritizing a city for on-the-ground reporting" and excludes it entirely.

#### Divisions
Divisions represent different regions of the United States, as defined by the [U.S. Census](https://www.ncdc.noaa.gov/monitoring-references/maps/us-census-divisions.php). This was an update made on 1-29-2021 with the understanding that we want greater geographic representation across the local reporting network. That's to say, perhaps both Detroit and Minneapolis rank highly, but since they're both in the East North Central division, it may be better for our impact to select one, and then find another high ranking city in a different division, e.g. Atlanta, which is in the South Atlantic. All divisions are selected by default, meaning that they are all included in the total ranking. Unselecting a division excludes it from the ranking process. 

#### Update Dashboard
You must click 'Update Dashboard' before the dashboard will render a map and a table.

## Feedback
If you have any questions or feedback, please contact me. 









