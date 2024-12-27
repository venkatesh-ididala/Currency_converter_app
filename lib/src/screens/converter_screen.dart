import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/amount_input_field.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/convert_button.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _fromCurrency;
  String? _toCurrency;
  double? _convertedAmount;
  List<String> _currencies = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    const apiUrl =
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json';
    const fallbackUrl =
        'https://latest.currency-api.pages.dev/v1/currencies.json';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _currencies = data.keys.toList();
        });
      } else {
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      final fallbackResponse = await http.get(Uri.parse(fallbackUrl));
      if (fallbackResponse.statusCode == 200) {
        final data = jsonDecode(fallbackResponse.body) as Map<String, dynamic>;
        setState(() {
          _currencies = data.keys.toList();
        });
      } else {
        throw Exception('Failed to load currencies from fallback');
      }
    }
  }

  Future<void> _convertCurrency() async {
    if (_fromCurrency == null ||
        _toCurrency == null ||
        _amountController.text.isEmpty) {
      return;
    }

    final apiUrl =
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$_fromCurrency.json';
    final fallbackUrl =
        'https://latest.currency-api.pages.dev/v1/currencies/$_fromCurrency.json';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = data['$_fromCurrency'] as Map<String, dynamic>;
        final rate = rates[_toCurrency] as double;

        setState(() {
          _convertedAmount = double.parse(_amountController.text) * rate;
        });
      } else {
        throw Exception('Failed to fetch conversion rate');
      }
    } catch (e) {
      final fallbackResponse = await http.get(Uri.parse(fallbackUrl));
      if (fallbackResponse.statusCode == 200) {
        final data = jsonDecode(fallbackResponse.body) as Map<String, dynamic>;
        final rates = data['$_fromCurrency'] as Map<String, dynamic>;
        final rate = rates[_toCurrency] as double;

        setState(() {
          _convertedAmount = double.parse(_amountController.text) * rate;
        });
      } else {
        throw Exception('Failed to fetch conversion rate from fallback');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AmountInputField(controller: _amountController),
            const SizedBox(height: 16.0),
            CurrencyDropdown(
              value: _fromCurrency,
              currencies: _currencies,
              hint: 'From Currency',
              onChanged: (value) {
                setState(() {
                  _fromCurrency = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            CurrencyDropdown(
              value: _toCurrency,
              currencies: _currencies,
              hint: 'To Currency',
              onChanged: (value) {
                setState(() {
                  _toCurrency = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            ConvertButton(
              onPressed: _convertCurrency,
            ),
            if (_convertedAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Converted Amount: $_convertedAmount $_toCurrency',
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
