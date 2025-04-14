import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/polygon_area.dart';
import 'package:latlong2/latlong.dart';


class PolygonService {
  final dio = Dio();
  final String baseUrl;

  PolygonService() : baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  Future<List<PolygonArea>> getPolygons({int? floor}) async {
    try {
      final response = await dio.get(
        "$baseUrl/rooms",
        queryParameters: floor != null ? {"floor": floor} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        return data.map((json) => PolygonArea.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load polygons');
      }
    } catch (e) {
      throw Exception('Failed to fetch polygons: $e');
    }
  }
List<PolygonArea> getMockPolygons() {
    const String mockJson = '''
    [{
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fdc"
    },
    "name": "RW1",
    "type": "EXHIBITION",
    "crowd_factor": 0.9881071813389886,
    "popularity_factor": 1.2130957889364573,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68878241688753, 12.5791298144814], [55.688783747190634, 12.579407114475128], [55.68841718918517, 12.579408033668447], [55.68841785434291, 12.579130733674722], [55.68846441535844, 12.579129553674743], [55.68846375020148, 12.579065833676186], [55.68854889020223, 12.579064653676209], [55.68854889020223, 12.579129553674743]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fdd"
    },
    "name": "KAFETERIA",
    "type": "EXHIBITION",
    "crowd_factor": 0.8850220129951176,
    "popularity_factor": 1.0262709092368454,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.688543568957684, 12.578541913688273], [55.68854290380205, 12.57864103368604], [55.68852161881597, 12.57864103368604], [55.688520288503966, 12.578649293685848], [55.688543568957684, 12.578820393681978], [55.68852228397196, 12.578820393681978], [55.68852095365998, 12.578831013681738], [55.68854290380205, 12.578829833681757], [55.688543568957684, 12.579064653676449], [55.68847106692763, 12.57906347367647], [55.68847106692763, 12.578829833681757], [55.68849301709771, 12.578829833681757], [55.68849301709771, 12.578821573681955], [55.68847239724131, 12.578821573681955], [55.68847173208449, 12.578650473685823], [55.68849301709771, 12.578650473685823], [55.68849301709771, 12.57864221368598], [55.68847173208449, 12.57864103368604], [55.68847173208449, 12.578540733688294]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fde"
    },
    "name": "107",
    "type": "EXHIBITION",
    "crowd_factor": 1.2113761043359343,
    "popularity_factor": 1.05784465464095,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.6887610742412, 12.579024533677364], [55.6887610742412, 12.57912601367505], [55.68870187567533, 12.579127193675028], [55.68870187567533, 12.579024533677364]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fdf"
    },
    "name": "106",
    "type": "EXHIBITION",
    "crowd_factor": 0.8437277848131974,
    "popularity_factor": 0.46675715507148263,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.6887610742412, 12.57893839367931], [55.68876173939312, 12.579015093677542], [55.68870320598113, 12.579016273677562], [55.68870187567533, 12.578937213679332]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe0"
    },
    "name": "105",
    "type": "EXHIBITION",
    "crowd_factor": 1.4160111897166103,
    "popularity_factor": 0.98834411063754,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.6887610742412, 12.578849893681301], [55.6887610742412, 12.57892895367953], [55.68870254082824, 12.578930133679505], [55.68870187567533, 12.578851073681276]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe1"
    },
    "name": "104",
    "type": "EXHIBITION",
    "crowd_factor": 0.4780002259348187,
    "popularity_factor": 0.9901825498203624,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.6887610742412, 12.578763753683244], [55.6887610742412, 12.578841633681497], [55.68870187567533, 12.578841633681497], [55.68870254082824, 12.578762573683269]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe2"
    },
    "name": "103",
    "type": "EXHIBITION",
    "crowd_factor": 0.6853240362068438,
    "popularity_factor": 1.282486730390145,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68876156755594, 12.578675479188734], [55.688760962784265, 12.578752726808352], [55.68870290465754, 12.578753799691976], [55.688701695112336, 12.578675479188734]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe3"
    },
    "name": "102",
    "type": "EXHIBITION",
    "crowd_factor": 0.5896547688587315,
    "popularity_factor": 0.7022177049977197,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.688760962784265, 12.578588575616632], [55.688760962784265, 12.578666896119875], [55.688701090339684, 12.578665823236294], [55.688701695112336, 12.578587502733052]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe4"
    },
    "name": "sal 101",
    "type": "EXHIBITION",
    "crowd_factor": 1.4212627757784635,
    "popularity_factor": 0.8365974055413034,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68869564738565, 12.578540295854364], [55.68869564738565, 12.579130381837642], [55.68855050166478, 12.579130381837642], [55.68854989688982, 12.578541368737989]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe5"
    },
    "name": "sal 100 (forhallen)",
    "type": "EXHIBITION",
    "crowd_factor": 0.9002712133030145,
    "popularity_factor": 0.3131767110565604,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68879717748983, 12.578052945417639], [55.68879657271869, 12.578494973463286], [55.68878689637904, 12.578494973463286], [55.68878568683641, 12.578532524389495], [55.68867561830092, 12.578531451505912], [55.68867501352789, 12.57843167333055], [55.68862421256006, 12.57843167333055], [55.68862421256006, 12.578440256399405], [55.68866896579708, 12.578439183515783], [55.68866896579708, 12.578531451505912], [55.68840649337894, 12.578531451505912], [55.68840649337894, 12.578352279943726], [55.68844398954656, 12.578350134176482], [55.68844338476994, 12.578199930471648], [55.68840649337894, 12.578198857588065], [55.68840709815613, 12.578018613142257], [55.68866896579708, 12.578019686025877], [55.68866836102394, 12.578109808248763], [55.68862360778623, 12.578110881132384], [55.68862360778623, 12.578119464201201], [55.68867501352789, 12.578120537084823], [55.688676223073934, 12.578018613142257], [55.688786291607734, 12.578018613142257], [55.688786291607734, 12.578052945417639]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe6"
    },
    "name": "sal 109",
    "type": "EXHIBITION",
    "crowd_factor": 0.7802003348211105,
    "popularity_factor": 0.8907156168875547,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.6887611033903, 12.577809669092755], [55.6887611033903, 12.577964164331995], [55.688702440491205, 12.577964164331995], [55.688701835718575, 12.577809669092755]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe7"
    },
    "name": "sal 108",
    "type": "EXHIBITION",
    "crowd_factor": 0.9907102874297101,
    "popularity_factor": 0.6740558344288134,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68867424716843, 12.577484204180015], [55.68867424716843, 12.578007771379687], [55.68854966372259, 12.578008844263309], [55.6885493875264, 12.577484254770186]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe8"
    },
    "name": "SHOP",
    "type": "EXHIBITION",
    "crowd_factor": 0.5456933648076111,
    "popularity_factor": 1.183431581571881,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.688544835986704, 12.577543043033243], [55.68854544076174, 12.577715777293818], [55.68852124975275, 12.577715777293818], [55.68852124975275, 12.577725433246256], [55.68854544076174, 12.577725433246256], [55.688544835986704, 12.577896021739626], [55.68852185452815, 12.577896021739626], [55.68852064497735, 12.577904604808442], [55.688544835986704, 12.577905677692064], [55.68854544076174, 12.578003310100222], [55.68847347246604, 12.578003310100222], [55.68847347246604, 12.577904604808442], [55.68849343007391, 12.577904604808442], [55.68849343007391, 12.577894948856006], [55.68847226291372, 12.577896021739626], [55.68847286768988, 12.577725433246256], [55.68849343007391, 12.577725433246256], [55.68849343007391, 12.577715777293818], [55.68847226291372, 12.577714704410196], [55.68847286768988, 12.57754089726604]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fe9"
    },
    "name": "LW1",
    "type": "EXHIBITION",
    "crowd_factor": 1.209828392440765,
    "popularity_factor": 0.8800275694600351,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68878301713443, 12.577144311436223], [55.68878301713443, 12.577418969639364], [55.688767293075834, 12.577418969639364], [55.68876658024279, 12.57780893287139], [55.68870186962619, 12.57780893287139], [55.68870126485356, 12.578018145174552], [55.688675864394945, 12.578018145174552], [55.68867525962194, 12.577483849138776], [55.68854949928773, 12.5774833885393], [55.68854768496276, 12.577541324254044], [55.68846483069954, 12.577541324254044], [55.688464225923276, 12.577420088406562], [55.688417658120905, 12.577420088406562], [55.68841753196904, 12.577143457542146]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fea"
    },
    "name": "114",
    "type": "EXHIBITION",
    "crowd_factor": 0.22517894570201907,
    "popularity_factor": 0.6669155004651831,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.689043531018875, 12.577035068538656], [55.68904292625154, 12.577367662456501], [55.68887177671887, 12.577367662456501], [55.68887117194886, 12.57715308573531], [55.68897882086063, 12.57715308573531], [55.68900180205059, 12.577033995655032]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6feb"
    },
    "name": "115",
    "type": "EXHIBITION",
    "crowd_factor": 1.2936174187200598,
    "popularity_factor": 1.1966549295310134,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68897530238703, 12.577508296663582], [55.68897530238703, 12.57768317669136], [55.68888216794421, 12.57768317669136], [55.68888216794421, 12.577509369547204]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fec"
    },
    "name": "117",
    "type": "EXHIBITION",
    "crowd_factor": 1.1320223449240012,
    "popularity_factor": 1.0923273390390509,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68904321620772, 12.577508564659846], [55.68904321620772, 12.577763910958073], [55.68888253611858, 12.577764363650916], [55.68888314088838, 12.577692480449326], [55.68898111347561, 12.577692480449326], [55.68898111347561, 12.57750901735273]]
  },
  {
    "_id": {
      "\$oid": "67efbb1f0b23f5290bff6fed"
    },
    "name": "STAGE",
    "type": "EXHIBITION",
    "crowd_factor": 0.9307145386567403,
    "popularity_factor": 0.4930131640344985,
    "occupants": 0,
    "area": 50,
    "longitude": 0,
    "latitude": 0,
    "floor": 1,
    "borders": [[55.68904372716422, 12.57776435514296], [55.68904270109071, 12.5786968929698], [55.688966711966536, 12.5786968929698], [55.688965719095144, 12.578457954820015], [55.68887765311902, 12.578457954820015], [55.68887704834912, 12.578068469106572], [55.688966202427935, 12.578068965040746], [55.68896578655848, 12.577831710313163], [55.68887698335998, 12.577832559106037], [55.688877588129884, 12.577764967438855]]
  }]
    ''';

    final List<dynamic> jsonData = jsonDecode(mockJson);
    return jsonData.map((json) => PolygonArea.fromJson(json)).toList();
  }
}