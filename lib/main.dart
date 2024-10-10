import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Курсы валют Узбекистана'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CurrencyList(),
        ),
      ),
    );
  }
}

class CurrencyList extends StatefulWidget {
  @override
  _CurrencyListState createState() => _CurrencyListState();
}

class _CurrencyListState extends State<CurrencyList> {
  late Future<List<dynamic>> currencyRates;

  @override
  void initState() {
    super.initState();
    currencyRates = fetchCurrencyRates();
  }

  Future<List<dynamic>> fetchCurrencyRates() async {
    final response = await http.get(Uri.parse('https://cbu.uz/ru/arkhiv-kursov-valyut/json/'));

    if (response.statusCode == 200) {
      // Парсим JSON, полученный от API
      return jsonDecode(response.body);
    } else {
      // Если ответ не успешен, выбрасываем ошибку
      throw Exception('Failed to load currency rates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: currencyRates,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> rates = snapshot.data!;

          // Фильтруем нужные валюты: USD, EUR, GBP, RUB, CNY
          var filteredRates = rates.where((rate) =>
              ['USD', 'EUR', 'GBP', 'RUB', 'CNY'].contains(rate['Ccy']));

          return ListView(
            children: filteredRates.map((rate) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  leading: CircleAvatar(
                    child: Text(rate['Ccy']),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(
                    '${rate['Ccy']} к UZS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Курс обмена: ${rate['Rate']}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(height: 5),
                      Text('Дата: ${rate['Date']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }

        // Показываем индикатор загрузки, пока данные не загружены
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
