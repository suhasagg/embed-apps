function bound(value, opt_min, opt_max) {
    if (opt_min != null) value = Math.max(value, opt_min);
    if (opt_max != null) value = Math.min(value, opt_max);
    return value;
}

function degreesToRadians(deg) {
    return deg * (Math.PI / 180);
}

function radiansToDegrees(rad) {
    return rad / (Math.PI / 180);
}

function MercatorProjection() {
    var MERCATOR_RANGE = 256;
    this.pixelOrigin_ = new google.maps.Point(
        MERCATOR_RANGE / 2, MERCATOR_RANGE / 2);
    this.pixelsPerLonDegree_ = MERCATOR_RANGE / 360;
    this.pixelsPerLonRadian_ = MERCATOR_RANGE / (2 * Math.PI);
};

MercatorProjection.prototype.fromLatLngToPoint = function(latLng, opt_point) {
    var me = this;

    var point = opt_point || new google.maps.Point(0, 0);

    var origin = me.pixelOrigin_;
    point.x = origin.x + latLng.lng() * me.pixelsPerLonDegree_;
    // NOTE(appleton): Truncating to 0.9999 effectively limits latitude to
    // 89.189.  This is about a third of a tile past the edge of the world tile.
    var siny = bound(Math.sin(degreesToRadians(latLng.lat())), -0.9999, 0.9999);
    point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) * -me.pixelsPerLonRadian_;
    return point;
};

MercatorProjection.prototype.fromDivPixelToLatLng = function(pixel, zoom) {
    var me = this;

    var origin = me.pixelOrigin_;
    var scale = Math.pow(2, zoom);
    var lng = (pixel.x / scale - origin.x) / me.pixelsPerLonDegree_;
    var latRadians = (pixel.y / scale - origin.y) / -me.pixelsPerLonRadian_;
    var lat = radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) - Math.PI / 2);
    return new google.maps.LatLng(lat, lng);
};

MercatorProjection.prototype.fromDivPixelToSphericalMercator = function(pixel, zoom) {
    var me = this;
    var coord = me.fromDivPixelToLatLng(pixel, zoom);

    var r = 6378137.0;
    var x = r * degreesToRadians(coord.lng());
    var latRad = degreesToRadians(coord.lat());
    var y = (r / 2) * Math.log((1 + Math.sin(latRad)) / (1 - Math.sin(latRad)));

    return new google.maps.Point(x, y);
};

// example ;

function map_get_bbox(tile, zoom) {
    var projection = map.getProjection();
    var zpow = Math.pow(2, zoom);
    var ul = new G.Point(tile.x * 256.0 / zpow, (tile.y + 1) * 256.0 / zpow);
    var lr = new G.Point((tile.x + 1) * 256.0 / zpow, (tile.y) * 256.0 / zpow);
    var ulw = projection.fromPointToLatLng(ul);
    var lrw = projection.fromPointToLatLng(lr);
    return ulw.lat() + "," + ulw.lng() + "," + lrw.lat() + "," + lrw.lng();
}

function map_get_title_url(current_wms, tile, zoom) {
    var bbox = map_get_bbox(tile, zoom);
    //add additional parameters
    //var wmsParams = wmsParams.concat(customParams);
    //The user will enter the address to the public WMS layer here.  The data must be in WGS84
    var baseURL = current_wms;
    var format = "image/png"; //type of image returned  or image/jpeg
    var crs = "EPSG:4326"; //projection to display. This is the projection of google map. Don't change unless you know what you are doing.
    //var url = baseURL + layers + "&Styles=default" + "&SRS=" + crs + "&BBOX=" + bbox + "&width=256" + "&height=256" + "&format=" + format + "&BGCOLOR=0xFFFFFF&TRANSPARENT=true" + "&reaspect=false" + "&CRS=" + crs;
    var url = baseURL + "&Layers=0&Styles=" + "&SRS=" + crs + "&BBOX=" + bbox + "&width=256" + "&height=256" + "&format=" + format + "&BGCOLOR=0xFFFFFF&TRANSPARENT=true" + "&reaspect=false" + "&CRS=" + crs;
    return url;
}

function add_wms_url(baseURL, layer_name) {


    var tileHeight = (baseURL.search(/=512/) == -1) ? 256 : 512;
    var tileWidth = (baseURL.search(/=512/) == -1) ? 256 : 512;
    var isPng = (baseURL.search(/png/) == -1);
    var minZoomLevel = 2;
    var maxZoomLevel = 28;

    var wmsParams = [
        /*    "REQUEST=GetMap",
         "SERVICE=WMS",
         "VERSION=1.3",
         "BGCOLOR=0xFFFFFF",
         "TRANSPARENT=TRUE",
         "SRS=EPSG:4326", // 3395?
         "WIDTH=" + tileWidth,
         "HEIGHT=" + tileHeight,
         "Styles=default",
         "FORMAT=image/jpeg",
         "LAYERS=0",
         "CRS=EPSG:4326"
         //"reaspect=false"
         */
    ];


    //Creating the object to create the ImageMapType that will call the WMS Layer Options.
    var overlayWMS = new google.maps.ImageMapType({
        getTileUrl: function(tile, zoom) {

            // compute bbox
            var projection = map.getProjection();
            var zpow = Math.pow(2, zoom);
            var ul = new google.maps.Point(tile.x * tileWidth / zpow, (tile.y + 1) * tileWidth / zpow);
            var lr = new google.maps.Point((tile.x + 1) * tileHeight / zpow, (tile.y) * tileHeight / zpow);
            var ulw = projection.fromPointToLatLng(ul);
            var lrw = projection.fromPointToLatLng(lr);
            var bbox = ulw.lat() + "," + ulw.lng() + "," + lrw.lat() + "," + lrw.lng();

            var urlResult = baseURL + wmsParams.join("&") + "&bbox=" + bbox;

            return urlResult;
        },isPng: isPng,
        maxZoom: maxZoomLevel,
        minZoom: minZoomLevel,
        name: layer_name,
        tileSize: new google.maps.Size(tileWidth, tileHeight)
    });

    map.mapTypes.set(layer_name, overlayWMS);
    map.setMapTypeId(layer_name);
}

function add_tile_url(url, image_type, layer_name) {

    /*
     Initialisation of the layer
     */
    var isPng = (image_type == "png");

    var options = {
        getTileUrl: function(tile, zoom) {
            var ymax = 1 << zoom;
            var y = ymax - tile.y - 1;
            return url + zoom + "/" + tile.x + "/" + y + "." + image_type;
        },
        tileSize: new google.maps.Size(256, 256),
        opacity:1.0,
        isPng: isPng,
        maxZoom: 20,
        name: layer_name
    };

    //add layer
    map.mapTypes.set(layer_name, new google.maps.ImageMapType(options));
}

$(function() {
   if (typeof(google)!="undefined")
    if (!google.maps.Polygon.prototype.getBounds) {


// + the first one
        google.maps.Polygon.prototype.getBounds = function(latLng) {
            var bounds = new google.maps.LatLngBounds();
            var paths = this.getPaths();
            var path;
            for (var p = 0; p < paths.getLength(); p++) {
                path = paths.getAt(p);
                for (var i = 0; i < path.getLength(); i++) {
                    bounds.extend(path.getAt(i));
                }
            }
            return bounds;
        }


// Polygon containsLatLng - method to determine if a latLng is within a polygon
        google.maps.Polygon.prototype.containsLatLng = function(latLng) {
            // Exclude points outside of bounds as there is no way they are in the poly
            var bounds = this.getBounds();

            if (bounds != null && !bounds.contains(latLng)) {
                return false;
            }

            // Raycast point in polygon method
            var inPoly = false;

            var numPaths = this.getPaths().getLength();
            for (var p = 0; p < numPaths; p++) {
                var path = this.getPaths().getAt(p);
                var numPoints = path.getLength();
                var j = numPoints - 1;

                for (var i = 0; i < numPoints; i++) {
                    var vertex1 = path.getAt(i);
                    var vertex2 = path.getAt(j);

                    if (vertex1.lng() < latLng.lng() && vertex2.lng() >= latLng.lng() || vertex2.lng() < latLng.lng() && vertex1.lng() >= latLng.lng()) {
                        if (vertex1.lat() + (latLng.lng() - vertex1.lng()) / (vertex2.lng() - vertex1.lng()) * (vertex2.lat() - vertex1.lat()) < latLng.lat()) {
                            inPoly = !inPoly;
                        }
                    }

                    j = i;
                }
            }
            return inPoly;
        }
    }

});