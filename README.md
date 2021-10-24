# chicagomapbot
Source code for a twitter bot that tweets random small-scale satellite images of Chicago every hour. Heavily sourced from and inspired by [@londonmapbot](https://twitter.com/londonmapbot) created by [@mattdray](https://twitter.com/mattdray). 

### Deviations
There's one deviation from [@londonmapbot](https://twitter.com/londonmapbot) that had to be implemented due to the physical geography of Chicago. When the script generates a random set of lat/lon coordinates within Chicago's bounding box, there's a good chance of it being on Lake Michigan. To avoid tweeting an image of water, I used {sf} and {geojsonsf} to load the municipal polygon boundary of Chicago (from [Chicago's Open Data Portal](https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-City/ewy2-6yfk)) and check if the initial random lat/lon point [intersects](http://wiki.gis.com/wiki/index.php/Intersect) Chicago's municipal boundary. If the initial random point doesn't intersect, the script generates new random points until it does.

### Flow

1. Github Actions (scheduled to run the scripts every hour)
2. Create random point
3. Does it intersect with Chicago's boundary? If not, generate a new point until it does.
4. Mapbox API (gets satellite imagery)
5. Twitter API via {rtweets} (posts tweet)
