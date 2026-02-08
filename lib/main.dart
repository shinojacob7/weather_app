import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  int temperature = 31;
  int feelsLike = 42;
  int humidity = 88;
  int heatIndex = 42;
  int windSpeed = 7;
  int rainfall = 7;
  int soilMoisture = 45;
  int visibility = 10;
  int pressure = 1012;

  String location = "Thiruvananthapuram, Kerala";

  String selectedCrop = "Rice (Paddy)";
  String selectedCropMalayalam = "നെല്ല്";

  void fetchWeatherData() {
    setState(() {
      temperature = 32;
      feelsLike = 44;
      humidity = 85;
      windSpeed = 9;
      rainfall = 8;
      soilMoisture = 48;
      pressure = 1009;
    });
  }

  Future<void> _useDeviceLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied.')));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.subAdministrativeArea ?? '';
        final region = p.administrativeArea ?? '';
        setState(() {
          location = [city, region].where((s) => s.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _cropSelector(),
              const SizedBox(height: 20),
              _temperatureCardClickable(),
              const SizedBox(height: 20),
              _recommendationCardClickable(),
              const SizedBox(height: 20),
              _farmingRecommendationsClickable(),
              const SizedBox(height: 20),
              _conditionsGrid(),
              const SizedBox(height: 20),
              _hourlyForecast(),
              const SizedBox(height: 20),
              _fiveDayForecast(),
              const SizedBox(height: 24),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.agriculture, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              "Kerala Agri Weather",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Use device location',
              onPressed: _useDeviceLocation,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchWeatherData,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18),
            const SizedBox(width: 4),
            Expanded(
              child: _AutoScrollText(
                text: location,
                style: Theme.of(context).textTheme.bodyMedium,
                stepOffset: 60,
              ),
            ),
            const Spacer(),
            const Text("Wednesday, January 28"),
          ],
        ),
      ],
    );
  }

  Widget _cropSelector() {
    return GestureDetector(
      onTap: _showCropSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.rice_bowl, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "$selectedCrop\n$selectedCropMalayalam",
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.green),
          ],
        ),
      ),
    );
  }

void _showCropSelector() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          
          
          children: [
            Row(
              children: [
                const Text(
                  "Select Your Crop",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _cropCard("Rice (Paddy)", "നെല്ല്", Icons.rice_bowl),
                _cropCard("Coconut", "തേങ്ങ", Icons.circle),
                _cropCard("Rubber", "റബ്ബർ", Icons.park),
                _cropCard("Tea", "ചായ", Icons.emoji_food_beverage),
                _cropCard("Coffee", "കാപ്പി", Icons.coffee),
                _cropCard("Black Pepper", "കുരുമുളക്", Icons.local_fire_department),
                _cropCard("Cardamom", "ഏലം", Icons.grass),
                _cropCard("Banana", "വാഴ", Icons.energy_savings_leaf),
                _cropCard("Tapioca", "കപ്പ", Icons.circle_outlined),
                _cropCard("Vegetables", "പച്ചക്കറികൾ", Icons.eco),
              ],
            ),
        ),
          ],
        ),
      );
    },
  );
}


  Widget _cropCard(String crop, String mal, IconData icon) {
    final isSelected = crop == selectedCrop;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCrop = crop;
          selectedCropMalayalam = mal;
        });
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.green),
            const SizedBox(height: 8),
            Text(crop, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(mal, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _temperatureCardClickable() => GestureDetector(
        onTap: fetchWeatherData,
        child: _temperatureCard(),
      );

Widget _temperatureCard() { 
  
  return Container( 
    width: double.infinity, 
    padding: const EdgeInsets.all(20), 
    decoration: BoxDecoration( 
      gradient: const LinearGradient( 
        colors: [Color(0xFFFF8C00), Color(0xFFFFB300)], 
      ), 
      borderRadius: BorderRadius.circular(20), 
    ), 
    child: Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [ 
        const Text( 
          "Current Temperature", 
          style: TextStyle(color: Colors.white70), 
        ), 
        const SizedBox(height: 8), 
        Row( 
          children: [ 
            Text( 
              "$temperature°", 
              style: const TextStyle( 
                fontSize: 56, 
                fontWeight: FontWeight.bold, 
                color: Colors.white, 
              ), 
            ), 
            const Text("C", style: TextStyle(color: Colors.white)), 
            const Spacer(), 
            const CircleAvatar( 
              radius: 24, 
              backgroundColor: Colors.white24, 
              child: Icon(Icons.thermostat, color: Colors.white), 
            ), 
          ], 
        ), 
        Text( 
          "Feels like $feelsLike°C", 
          style: const TextStyle(color: Colors.white70), 
        ), 
        const Divider(color: Colors.white30, height: 30), 
        Row(
  children: [
    Expanded(
      child: _TempInfo(
        label: "Heat Index",
        value: "$heatIndex°C",
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: _TempInfo(
        label: "Humidity",
        value: "$humidity%",
      ),
    ),
  ],
),
 
      ], 
    ), 
  ); 
} 

Widget _recommendationCardClickable() { 
  return GestureDetector( 
    onTap: () { 
      print("Recommendation card clicked"); 
    }, 
    child: _recommendationCard(), 
  ); 
} 

Widget _recommendationCard() { 
  return Container( 
    padding: const EdgeInsets.all(16), 
    decoration: BoxDecoration( 
      color: Colors.white, 
      borderRadius: BorderRadius.circular(18), 
    ), 
    child: Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [ 
        const Text( 
          "Rice (Paddy) - Weather Recommendation", 
          style: TextStyle(fontWeight: FontWeight.bold), 
        ), 
        const SizedBox(height: 12), 
        Container( 
          padding: const EdgeInsets.all(14), 
          decoration: BoxDecoration( 
            color: const Color(0xFFEFF5FF), 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: Colors.blue), 
          ), 
          child: const Row( 
            children: [ 
              Icon(Icons.info_outline, color: Colors.blue), 
              SizedBox(width: 10), 
              Expanded( 
                child: Text( 
                  "Good Conditions\nSuitable conditions for rice growth", 
                ), 
              ), 
            ], 
          ), 
        ), 
      ], 
    ), 
  ); 
} 

Widget _farmingRecommendationsClickable() { 
  return Column( 
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [ 
      const Text( 
        "Farming Recommendations", 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
      ), 
      const SizedBox(height: 12), 
      _InfoTileClickable( 
        icon: Icons.water_drop, 
        color: const Color(0xFFEFF5FF), 
        title: "Irrigation", 
        text: "Maintain current irrigation schedule. Keep 2-5cm water depth in fields.", 
      ), 
      _InfoTileClickable( 
        icon: Icons.spa, 
        color: const Color(0xFFEFFAF0), 
        title: "Fertilization", 
        text: "Apply NPK in split doses. First dose at 15 days after transplanting.", 
      ), 
      _InfoTileClickable( 
        icon: Icons.bug_report, 
        color: const Color(0xFFFFF3E0), 
        title: "Pest & Disease Control", 
        text: "High humidity increases disease risk. Monitor blast disease.", 
      ), 
      _InfoTileClickable( 
        icon: Icons.info, 
        color: const Color(0xFFF5F5F5), 
        title: "General Care", 
        text: "Regular weeding required. Remove weeds 20 & 40 days after transplanting.", 
      ), 
    ], 
  ); 
} 

Widget _conditionsGridClickable() { 
  return _conditionsGrid(); 
} 

Widget _conditionsGrid() {
  return Container( 
    padding: const EdgeInsets.all(16), 
    decoration: BoxDecoration( 
      color: Colors.white, 
      borderRadius: BorderRadius.circular(18), 
    ), 
    child: Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [ 
        const Text( 
          "Farm Weather Conditions", 
          style: TextStyle(fontWeight: FontWeight.bold), 
        ), 
        const SizedBox(height: 14), 
        GridView.count( 
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          crossAxisCount: 2, 
          crossAxisSpacing: 12, 
          mainAxisSpacing: 12, 
          childAspectRatio: 2.8, 
          children: [ 
            _SmallConditionItem(Icons.water_drop, const Color(0xFFE3F2FD), "Humidity", "$humidity%"), 
            _SmallConditionItem(Icons.air, const Color(0xFFF1F3F4), "Wind Speed", "$windSpeed km/h"), 
            _SmallConditionItem(Icons.grain, const Color(0xFFE8EAF6), "Rainfall", "$rainfall mm"), 
            _SmallConditionItem(Icons.eco, const Color(0xFFE8F5E9), "Soil Moisture", "$soilMoisture%"), 
            _SmallConditionItem(Icons.visibility, const Color(0xFFF3E5F5), "Visibility", "$visibility km"), 
            _SmallConditionItem(Icons.speed, const Color(0xFFFFF3E0), "Pressure", "$pressure mb"), 
          ], 
        ), 
      ], 
    ), 
  ); 
} 

Widget _hourlyForecastClickable() { 
  return _hourlyForecast(); 
} 

Widget _hourlyForecast() { 
  return Column( 
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [ 
      const Text( 
        "24-Hour Forecast", 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
      ), 
      const SizedBox(height: 12), 
      SizedBox( 
        height: 110, 
        child: ListView.builder( 
          scrollDirection: Axis.horizontal, 
          itemCount: 6, 
          itemBuilder: (_, i) => GestureDetector( 
            onTap: () { 
              print("Hourly item $i clicked"); 
            }, 
            child: Container( 
              width: 90, 
              margin: const EdgeInsets.only(right: 12), 
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration( 
                color: Colors.white, 
                borderRadius: BorderRadius.circular(14), 
              ), 
              child: const Column( 
                children: [ 
                  Text("9 AM"), 
                  Icon(Icons.wb_sunny, color: Colors.orange), 
                  Text( 
                    "93°", 
                    style: TextStyle(fontWeight: FontWeight.bold), 
                  ), 
                  Text( 
                    "Heat 134°", 
                    style: TextStyle(color: Colors.red, fontSize: 12), 
                  ), 
                ], 
              ), 
            ), 
          ), 
        ), 
      ), 
    ], 
  ); 
} 

Widget _fiveDayForecastClickable() { 
  return _fiveDayForecast(); 
} 

Widget _fiveDayForecast() { 
  return Container( 
    padding: const EdgeInsets.all(16), 
    decoration: BoxDecoration( 
      color: Colors.white, 
      borderRadius: BorderRadius.circular(18), 
    ), 
    child: Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: List.generate( 
        5, 
        (index) => GestureDetector( 
          onTap: () { 
            print("5-day item $index clicked"); 
          }, 
          child: const ListTile( 
            leading: Icon(Icons.cloud, color: Colors.orange), 
            title: Text("Thu"), 
            subtitle: Text("High / Low 88° / 64°"), 
            trailing: Text( 
              "95°F", 
              style: TextStyle(color: Colors.orange), 
            ), 
          ), 
        ), 
      ), 
    ), 
  ); 
} 

Widget _footerClickable() { 
  return _footer(); 
} 

Widget _footer() { 
  return Container( 
    width: double.infinity, 
    padding: const EdgeInsets.all(16), 
    decoration: BoxDecoration( 
      color: const Color(0xFFEFFAF0), 
      borderRadius: BorderRadius.circular(16), 
    ), 
    child: const Column( 
      children: [ 
        Text("Last updated: 7:27 AM"), 
        SizedBox(height: 6), 
        Text( 
          "Kerala Agricultural Weather Advisory System\nPowered by real-time weather data for farmers", 
          textAlign: TextAlign.center, 
          style: TextStyle(fontSize: 12), 
        ), 
      ], 
    ), 
  ); 
} 

}

class _AutoScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double stepOffset; // pixels per second
  const _AutoScrollText({required this.text, this.style, this.stepOffset = 50, super.key});

  @override
  State<_AutoScrollText> createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<_AutoScrollText> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrollLoop());
  }

  Future<void> _startScrollLoop() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;
    while (mounted) {
      await _controller.animateTo(
        max,
        duration: Duration(milliseconds: (max / widget.stepOffset * 1000).toInt()),
        curve: Curves.linear,
      );
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 600));
      await _controller.animateTo(
        0,
        duration: Duration(milliseconds: (max / widget.stepOffset * 1000).toInt()),
        curve: Curves.linear,
      );
      if (!mounted) break;
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, style: widget.style ?? Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _TempInfo extends StatelessWidget { 
  final String label; 
  final String value; 
  const _TempInfo({required this.label, required this.value}); 
  @override 
  Widget build(BuildContext context) { 
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [ 
        Text(label, style: const TextStyle(color: Colors.white70)), 
        Text( 
          value, 
          style: const TextStyle( 
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
          ), 
        ), 
      ], 
    ); 
  } 
} 

class _InfoTileClickable extends StatelessWidget { 
  final IconData icon; 
  final Color color; 
  final String title; 
  final String text; 
  const _InfoTileClickable({ 
    required this.icon, 
    required this.color, 
    required this.title, 
    required this.text, 
  }); 
  @override 
  Widget build(BuildContext context) { 
    return GestureDetector( 
      onTap: () { 
        print("$title tile clicked"); 
      }, 
      child: Container( 
        margin: const EdgeInsets.only(bottom: 12), 
        padding: const EdgeInsets.all(14), 
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)), 
        child: Row( 
          children: [ 
            Icon(icon), 
            const SizedBox(width: 12), 
            Expanded( 
              child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [ 
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), 
                  const SizedBox(height: 4), 
                  Text(text), 
                ], 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
} 

class _SmallConditionItem extends StatelessWidget { 
  final IconData icon; 
  final Color bgColor; 
  final String label; 
  final String value; 
  const _SmallConditionItem(this.icon, this.bgColor, this.label, this.value); 
  @override 
  Widget build(BuildContext context) { 
    return Container( 
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
      decoration: BoxDecoration( 
        color: bgColor, 
        borderRadius: BorderRadius.circular(14), 
      ), 
      child: Row( 
        children: [ 
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),


        ], 
      ), 
    ); 
  } 
}
