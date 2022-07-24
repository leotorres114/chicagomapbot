# twitter twoken
chimapbot_token <- rtweet::rtweet_bot(
  api_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

#get chicago geometry
geo <- geojsonsf::geojson_sf('geo/chi.geojson')

# Generate intial random coords within Chicago bounding box
lon <- round(runif(1, -87.94011, -87.52414), 4)
lat <- round(runif(1, 41.64454, 42.02304), 4)

#convert coords to point sf object
point <- sf::st_as_sf(
  data.frame(lon = lon, lat = lat),
  coords = c("lon", "lat"),
  crs = sf::st_crs(geo)
)

#def not the best way to do this, but here we are checking if the random
#coords intersect the polygon boundary of Chicago. I'm doing this cause
#Chicago's bounding box contains a lot of water (Lake Michigan) and
#we don't want to waste our API queries on a static image of water

# it regenerates our lat/lon until is.na(st_intersects) returns FALSE
# so far, it's taken less than 3 loops. kinda shit code tho.
while (is.na(as.logical(sf::st_intersects(point, geo))) == TRUE) {
  lon <- round(runif(1, -87.94011, -87.52414), 4)
  lat <- round(runif(1, 41.64454, 42.02304), 4)
  
  point <- sf::st_as_sf(
    data.frame(lon = lon, lat = lat),
    coords = c("lon", "lat"),
    crs = sf::st_crs(geo)
  )
}

img_url <- paste0(
  "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/",
  paste0(lon, ",", lat),
  ",16,0/400x300@2x?access_token=",
  Sys.getenv("MAPBOX_PUBLIC_ACCESS_TOKEN")
)

temp_file <- tempfile(fileext = ".jpeg")
download.file(img_url, temp_file)

# Build the status message (text and URL)
status <- paste0(lat,", ",lon,"\n",
                 "https://www.openstreetmap.org/#map=18/",lat,"/",lon,"/")

alt_text <- "A satellite image of a random location in Chicago."

# Post the image to Twitter
rtweet::post_tweet(status = status,
                   media = temp_file,
                   media_alt_text = alt_text,
                   token = chimapbot_token)