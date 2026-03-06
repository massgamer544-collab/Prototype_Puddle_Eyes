import 'dart:io';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';
import 'tracking_service.dart';

class ExportService {
    static Future<String> exportGPX() async {
        final gpx = GPX();

        for(var obs in TrackingService.getAllObstacles()) {
            final wpt = Wpt(lat: obs.lat, lon: obs.lon, ele: obs.depth, time: obs.timestamp);
            gpx.wpts.add(wpt);
        }

        final gpxString = GpxWriter().asString(gpx, pretty: true);

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/puddleeyes_track_${DateTime.now(),millisecondsSinceEpoch}.gpx');
        await file.writeAsString(gpxString);

        return file.path; // retourne le chemin du fichier GPX crée
    }

    // Nouvelle fonction : Export KML
    static Future<String> exportKML() async {
        final obstacles = TrackingService.getAllObstacles();

        final kmlBuffer = StringBuffer();
        kmlBuffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
        kmlBuffer.writeln('<kml xmlns="http://www.opengis.net/kml/2.2">');
        kmlBuffer.writeln('<Document>');
        kmlBuffer.writeln('<name>PuddleEyes Track</name>');

        for (var obs in obstacles){
            kmlBuffer.writeln('<Placemark>');
            kmlBuffer.writeln('<name>Obstacle ${obs.timestamp}</name>');
            kmlBuffer.writeln('<description>Depth: ${obs.depth}m</description>');
            kmlBuffer.writeln('<Point>');
            kmlBuffer.writeln('<coordinates>${obs.lon},${obs.lat},0</coordinates>');
            kmlBuffer.writeln('</Point>');
            kmlBuffer.writeln('</Placemark>');
        }

        kmlBuffer.writeIn('</Document>')
        kmlBuffer.writeIn('</kml>')

        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/puddleeyes_track_${DateTime.now(),millisecondsSinceEpoch}.kml');
        await file.writeAsString(kmlBuffer.toString());

        return file.path; 

    }
}