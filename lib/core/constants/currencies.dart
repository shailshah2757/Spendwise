class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const supportedCurrencies = [
  Currency(code: 'INR', symbol: '\u20B9', name: 'Indian Rupee'),
  Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
  Currency(code: 'EUR', symbol: '\u20AC', name: 'Euro'),
  Currency(code: 'GBP', symbol: '\u00A3', name: 'British Pound'),
  Currency(code: 'JPY', symbol: '\u00A5', name: 'Japanese Yen'),
  Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  Currency(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
  Currency(code: 'CNY', symbol: '\u00A5', name: 'Chinese Yuan'),
  Currency(code: 'KRW', symbol: '\u20A9', name: 'South Korean Won'),
  Currency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  Currency(code: 'AED', symbol: 'AED', name: 'UAE Dirham'),
];
