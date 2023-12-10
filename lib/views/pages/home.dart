part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<Province> provinceData = [];
  bool isLoading = false;

  // variable
  dynamic jasaPengiriman;
  // province
  dynamic provinceList;
  dynamic selectedProvinceOrigin;
  dynamic selectedProvinceDestination;
  // city
  dynamic cityOriginList;
  bool originCityLoading = false;
  dynamic selectedCityOrigin;
  dynamic cityOriginId;
  dynamic cityDestinationList;
  bool destinationCityLoading = false;
  dynamic selectedCityDestination;
  dynamic cityDestinationId;
  // calculate costs
  List<Costs> calculateCost = [];
  bool checkCostLoading = false;
  dynamic dataLength;

  TextEditingController beratBarang = TextEditingController();

  // ambil data yang asingkronus(yang perlu login dll), fungsi mengembalikan nilai berupa list
  Future<List<Province>> getProvinces() async {
    dynamic prov;
    await MasterDataService.getProvince().then((value) {
      setState(() {
        prov = value;
        isLoading = false;
      });
    });
    return prov;
  }

  // fungsion ambil data city
  Future<List<City>> getCities(var provinceId) async {
    dynamic city;
    await MasterDataService.getCity(provinceId).then((value) {
      setState(() {
        city = value;
      });
    });
    return city;
  }

  //fungsion ambil data costs
  Future<List<Costs>> getCosts(
      var origin, var destinationId, var weight, var courier) async {
    try {
      List<Costs> costs = await MasterDataService.getCosts(
        origin,
        destinationId,
        weight,
        courier,
      );
      setState(() {
        dataLength = costs.length;
      });
      return costs;
    } catch (error) {
      return [];
    }
  }

// fungsi yang dijalankan pertama saat page tersebut dibuka
  @override
  void initState() {
    // To do: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    provinceList = getProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Hitung Ongkir",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue.shade800,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // drop down list
                            Expanded(
                              flex: 1,
                              child: DropdownButton<String>(
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 30,
                                elevation: 4,
                                value: jasaPengiriman,
                                hint: jasaPengiriman == null
                                    ? const Text("Jasa Pengiriman")
                                    : Text(jasaPengiriman),
                                onChanged: (String? value) {
                                  setState(() {
                                    jasaPengiriman = value;
                                  });
                                },
                                items: <String>[
                                  'JNE',
                                  'TIKI',
                                  'POS',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value.toLowerCase(),
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: beratBarang,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  label: Text("berat"),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Origin text
                        const Row(
                          children: [
                            Text("Origin",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                        Row(
                          children: [
                            // dropdown provinsi
                            Expanded(
                              flex: 3,
                              child: FutureBuilder<List<Province>>(
                                future: provinceList,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      value: selectedProvinceOrigin,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      hint: selectedProvinceOrigin == null
                                          ? const Text("Provinsi")
                                          : Text(
                                              selectedProvinceOrigin.province),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<Province>>(
                                              (Province itemProvince) {
                                        return DropdownMenuItem(
                                            value: itemProvince,
                                            child: Text(itemProvince.province
                                                .toString()));
                                      }).toList(),
                                      onChanged: (newItemProvince) {
                                        setState(() {
                                          selectedProvinceOrigin = null;
                                          selectedProvinceOrigin =
                                              newItemProvince;
                                          originCityLoading = true;
                                          cityOriginList = getCities(
                                              selectedProvinceOrigin.provinceId
                                                  .toString());
                                          originCityLoading = false;
                                        });
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text("No Data");
                                  }
                                  return DropdownButton(
                                    isExpanded: true,
                                    value: selectedCityOrigin,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    elevation: 4,
                                    style: const TextStyle(color: Colors.black),
                                    items: const [],
                                    onChanged: (value) {
                                      Null;
                                    },
                                    isDense: false,
                                    hint: const Text('Select an item'),
                                    disabledHint: const Text('Pilih kota'),
                                  );
                                },
                              ),
                            ),
                            const Spacer(
                              flex: 1,
                            ),
                            //drop down city
                            Expanded(
                              flex: 3,
                              child: FutureBuilder<List<City>>(
                                future: cityOriginList,
                                builder: (context, snapshot) {
                                  if (originCityLoading ||
                                      snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                    return UiLoading.loadingSmall();
                                  }
                                  if (snapshot.hasData) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      value: selectedCityOrigin,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      hint: selectedCityOrigin == null
                                          ? const Text("Pilih Kota")
                                          : Text(selectedCityOrigin.cityName),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<City>>(
                                              (City itemCity) {
                                        return DropdownMenuItem(
                                            value: itemCity,
                                            child: Text(
                                                itemCity.cityName.toString()));
                                      }).toList(),
                                      onChanged: (newItemCity) {
                                        setState(() {
                                          selectedCityOrigin = newItemCity;
                                          cityOriginId = selectedCityOrigin
                                              .cityId
                                              .toString();
                                        });
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text("No Data");
                                  }
                                  return DropdownButton(
                                    isExpanded: true,
                                    value: selectedCityOrigin,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    elevation: 4,
                                    style: const TextStyle(color: Colors.black),
                                    items: const [],
                                    onChanged: (value) {
                                      Null;
                                    },
                                    isDense: false,
                                    hint: const Text('Select an item'),
                                    disabledHint: const Text('Pilih kota'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        // Destination text
                        const Row(
                          children: [
                            Text("Destination",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                        Row(
                          children: [
                            // dropdown provinsi selected
                            Expanded(
                              flex: 3,
                              child: FutureBuilder<List<Province>>(
                                future: provinceList,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      value: selectedProvinceDestination,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      hint: selectedProvinceDestination == null
                                          ? const Text("Provinsi")
                                          : Text(selectedProvinceDestination
                                              .province),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<Province>>(
                                              (Province itemProvince) {
                                        return DropdownMenuItem(
                                            value: itemProvince,
                                            child: Text(itemProvince.province
                                                .toString()));
                                      }).toList(),
                                      onChanged: (newItemProvince) {
                                        setState(() {
                                          selectedProvinceDestination = null;
                                          selectedProvinceDestination =
                                              newItemProvince;
                                          destinationCityLoading = true;
                                          cityDestinationList = getCities(
                                              selectedProvinceDestination
                                                  .provinceId
                                                  .toString());
                                          destinationCityLoading = false;
                                        });
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text("No Data");
                                  }
                                  return DropdownButton(
                                    isExpanded: true,
                                    value: selectedCityOrigin,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    elevation: 4,
                                    style: const TextStyle(color: Colors.black),
                                    items: const [],
                                    onChanged: (value) {
                                      Null;
                                    },
                                    isDense: false,
                                    hint: const Text('Select an item'),
                                    disabledHint: const Text('Pilih kota'),
                                  );
                                },
                              ),
                            ),
                            const Spacer(
                              flex: 1,
                            ),
                            //drop down city
                            Expanded(
                              flex: 3,
                              child: FutureBuilder<List<City>>(
                                future: cityDestinationList,
                                builder: (context, snapshot) {
                                  if (destinationCityLoading ||
                                      snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                    return UiLoading.loadingSmall();
                                  }
                                  if (snapshot.hasData) {
                                    return DropdownButton(
                                      isExpanded: true,
                                      value: selectedCityDestination,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      elevation: 4,
                                      hint: selectedCityDestination == null
                                          ? const Text("Pilih Kota")
                                          : Text(
                                              selectedCityDestination.cityName),
                                      items: snapshot.data
                                          ?.map<DropdownMenuItem<City>>(
                                              (City itemCity) {
                                        return DropdownMenuItem(
                                            value: itemCity,
                                            child: Text(
                                                itemCity.cityName.toString()));
                                      }).toList(),
                                      onChanged: (newItemCity) {
                                        setState(() {
                                          selectedCityDestination = newItemCity;
                                          cityDestinationId =
                                              selectedCityDestination.cityId
                                                  .toString();
                                        });
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Text("No Data");
                                  }
                                  return DropdownButton(
                                    isExpanded: true,
                                    value: selectedCityOrigin,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    elevation: 4,
                                    style: const TextStyle(color: Colors.black),
                                    items: const [],
                                    onChanged: (value) {
                                      Null;
                                    },
                                    isDense: false,
                                    hint: const Text('Select an item'),
                                    disabledHint: const Text('Pilih kota'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Button
                Flexible(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade500,
                              shape: const LinearBorder(),
                            ),
                            onPressed: () async {
                              calculateCost = await getCosts(
                                  cityOriginId,
                                  cityDestinationId,
                                  beratBarang.text,
                                  jasaPengiriman);
                              setState(() {
                                checkCostLoading = true;
                              });
                            },
                            child: const Text(
                              'Hitung Estimasi Harga',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // output
                Flexible(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: calculateCost.isEmpty
                        ? const Align(
                            alignment: Alignment.center,
                            child: Text("Hitung Harga Jasa Ongkir"),
                          )
                        : ListView.builder(
                            itemCount: dataLength,
                            itemBuilder: (context, index) {
                              return CardCosts(calculateCost[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          isLoading == true ? UiLoading.loadingBlock() : Container()
        ],
      ),
    );
  }
}
