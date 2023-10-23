import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'key.dart' as key;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Iklim Cuaca',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cuaca Iklim'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

String? _kotaInput;

  Future _goToNextPage(BuildContext context) async {
    Map result =  await Navigator.of(context).push(MaterialPageRoute<dynamic>(builder:(context) {
      return changeCity();
    }
    )
  );
    if (result != null && result.containsKey("kota")) {
      _kotaInput = result["kota"].toString();
      //print(result["kota"].toString());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            onPressed: () {
              _goToNextPage(context);
            }, 
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset('images/cloudy.jpg', fit: BoxFit.fill, color: Colors.white.withOpacity(0.8),
            colorBlendMode: BlendMode.modulate,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            child: Text(
              '${_kotaInput == null ? key.defaultCity : _kotaInput}', 
              style: kotaStyle,
            ),
            margin: EdgeInsets.fromLTRB(0.0,11,20,0),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset('images/cloud.png'),
            width: 200,
            height: 150,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(0.0,150,20,0),
            //child: _updateTempWidget(_kotaInput ?? key.defaultCity), // aplikasi error jika ada code di barisan ini
          ),
        ]),
    );
  }
}


TextStyle kotaStyle = const TextStyle(
  fontSize: 30,
  color: Colors.blue,

);

class changeCity extends StatelessWidget {
  var kotaFieldCOntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pilih kota'),
        centerTitle: true,

      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset('images/cloud.png',
            fit: BoxFit.fill,alignment: Alignment.center,
            ),
          ),
          ListView(
            children: [
              ListTile(
                    title: TextField(
                  decoration: InputDecoration(hintText: 'Cari Kota'),
                  controller: kotaFieldCOntroller,
                  keyboardType: TextInputType.text,
                )
                ),
              ListTile(
                title: TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'kota': kotaFieldCOntroller.text});
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: Text('pilih',style: TextStyle(color:Colors.white,),),
                ),),
            ],
            ),
        ]));
  }
}

Future<Map> getWeather(String apiID, String city) async {
 var apiUrl = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiID&units=metric');
  http.Response response = await http.get(apiUrl);

  return json.decode(response.body);
}

Widget _updateTempWidget(String city){
  return FutureBuilder(
    future: getWeather(key.apiID, city),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        Map data = snapshot.data as Map;
        return Container(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  data['main']['temp'].toString() + "\u00B0C",
                  style: tempStyle(),
                ),
                subtitle: ListTile(
                  title: Text(
                    "Humidity: " + data['main']['humidity'].toString() + '%\n'
                        "Wind: " + data['wind']['speed'].toString() + 'km/h\n'
                        "Min :"  + data['main']['temp_min'].toString() + 'C\n'
                        "Max :"  + data['main']['temp_max'].toString() + 'C\n',
                        style: tempStyle(),
                  ),
                ),
              )
            ],
          ),
        );
      }else{
        return Container();
      }
    },
    );
}
TextStyle tempStyle() {
  return const TextStyle(
    fontSize: 30,
    color: Colors.blue,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500
  );
}