part of 'services.dart';

class MasterDataService {
  static Future<List<Province>> getProvince() async {
    var response = await http.get(Uri.https(Const.baseUrl, "/starter/province"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        });

    var job = json.decode(response.body);
    List<Province> result = [];

    if (response.statusCode == 200) {
      result = (job['rajaongkir']['results'] as List)
          .map((e) => Province.fromJson(e))
          .toList();
    }
    return result;
  }

//function ambil city
  static Future<List<City>> getCity(var provinceId) async {
    var response = await http.get(Uri.https(Const.baseUrl, "/starter/city"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        });

    var job = json.decode(response.body);
    List<City> city = [];
    if (response.statusCode == 200) {
      city = (job['rajaongkir']['results'] as List)
          .map((e) => City.fromJson(e))
          .toList();
    }

    List<City> cityFilter = [];

    for (var item in city) {
      if (item.provinceId == provinceId) {
        cityFilter.add(item);
      }
    }

    return cityFilter;
  }

  // function ambil costs
  static Future<List<Costs>> getCosts(
      var origin, var destinationId, var weight, var courier) async {
    final Map<String, dynamic> reqData = {
      "origin": origin,
      "destination": destinationId,
      "weight": weight,
      "courier": courier
    };
    var response = await http.post(Uri.https(Const.baseUrl, "/starter/cost"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        },
        body: jsonEncode(reqData));

    var job = json.decode(response.body);
    // print(job.toString());
    List<Costs> result = [];

    if (response.statusCode == 200) {
      result = (job['rajaongkir']['results'][0]['costs'] as List)
          .map((e) => Costs.fromJson(e))
          .toList();
    }
    return result;
  }
}
