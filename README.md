# local_reporting
Code and files related to the Local Reporting Dashboard

This tool was developed to help prioritize cities for a local reporting initiative. It incorporates 2020 data from the U.S. Census Bureau (for ZCTA level demographic projections), UNC's Expanding Media Desert project, the Center for Community Media's Black Media Initiative, CUNY's Latino News Media Map, the Institute for Nonprofit News' Member Directory, the National Association of Black Journalists' Chapters page, and the Gun Violence Archive.

In its current form, this data is updated manually. I outline the opportunities to automate this for each data source below:

U.S. Census Bureau ZCTA level demographic projections: There are APIs available for pulling this data. I haven't looked into how frequently projections are updated, but my gut tells me that it's <= once a year.

[UNC's Expanding Media Desert Project](https://www.usnewsdeserts.com/reports/news-deserts-and-ghost-newspapers-will-local-news-survive/): I had to personally request access to UNC's Media Desert data, and it's unclear how often this is refreshed. They emailed me a single XLSX file that includes newspapers in 2004, 2014, 2016, and 2020, along with newspaper closures from 2004-2019 (according to tab names). 

Center for Community Media's Black Media Initiative: 

