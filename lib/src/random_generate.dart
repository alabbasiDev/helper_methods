import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

const maxSupportedInteger = 999999999999999;
const minSupportedInteger = 0;
const asciiStart = 33;
const asciiEnd = 126;
const numericStart = 48;
const numericEnd = 57;
const lowerAlphaStart = 97;
const lowerAlphaEnd = 122;
const upperAlphaStart = 65;
const upperAlphaEnd = 90;

final _internal = Random();

/// A generator of double values.
abstract mixin class AbstractRandomProvider {
  /// A non-negative random floating point value is expected
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  /// A [ProviderError] is thrown if the return value is < 0 or >= 1
  double nextDouble();
}

/// A generator of pseudo-random double values using the default [math.Random].
class DefaultRandomProvider with AbstractRandomProvider {
  const DefaultRandomProvider();

  @override
  double nextDouble() => _internal.nextDouble();
}

/// A generator of random values using a supplied [math.Random].
class CoreRandomProvider with AbstractRandomProvider {
  Random random;

  CoreRandomProvider.from(this.random);

  @override
  double nextDouble() => random.nextDouble();
}

/// Generates a random integer where [from] <= [to] inclusive
/// where 0 <= from <= to <= 999999999999999
int randomBetween(
  int from,
  int to, {
  AbstractRandomProvider provider = const DefaultRandomProvider(),
}) {
  if (from > to) {
    throw ArgumentError('$from cannot be > $to');
  }
  if (from < minSupportedInteger) {
    throw ArgumentError(
      '|$from| is larger than the maximum supported $maxSupportedInteger',
    );
  }

  if (to > maxSupportedInteger) {
    throw ArgumentError(
      '|$to| is larger than the maximum supported $maxSupportedInteger',
    );
  }

  var d = provider.nextDouble();
  if (d < 0 || d >= 1) {
    throw ProviderError(d);
  }
  return _mapValue(d, from, to);
}

int _mapValue(double value, int min, int max) {
  if (min == max) return min;
  var range = (max - min).toDouble();
  return (value * (range + 1)).floor() + min;
}

/// Generates a random string of [length] with characters
/// between ascii [from] to [to].
/// Defaults to characters of ascii '!' to '~'.
String randomString(
  int length, {
  int from = asciiStart,
  int to = asciiEnd,
  AbstractRandomProvider provider = const DefaultRandomProvider(),
}) {
  return String.fromCharCodes(
    List.generate(
      length,
      (index) => randomBetween(from, to, provider: provider),
    ),
  );
}

/// Generates a random string of [length] with only numeric characters.
String randomNumeric(
  int length, {
  AbstractRandomProvider provider = const DefaultRandomProvider(),
}) => randomString(
  length,
  from: numericStart,
  to: numericEnd,
  provider: provider,
);

/// Generates a random string of [length] with only alpha characters.
String randomAlpha(
  int length, {
  AbstractRandomProvider provider = const DefaultRandomProvider(),
}) {
  var lowerAlphaWeight = provider.nextDouble();
  var upperAlphaWeight = provider.nextDouble();
  var sumWeight = lowerAlphaWeight + upperAlphaWeight;
  lowerAlphaWeight /= sumWeight;
  upperAlphaWeight /= sumWeight;
  var lowerAlphaLength = randomBetween(0, length, provider: provider);
  var upperAlphaLength = length - lowerAlphaLength;
  var lowerAlpha = randomString(
    lowerAlphaLength,
    from: lowerAlphaStart,
    to: lowerAlphaEnd,
    provider: provider,
  );
  var upperAlpha = randomString(
    upperAlphaLength,
    from: upperAlphaStart,
    to: upperAlphaEnd,
    provider: provider,
  );
  return randomMerge(lowerAlpha, upperAlpha);
}

/// Generates a random string of [length] with alpha-numeric characters.
String randomAlphaNumeric(
  int length, {
  AbstractRandomProvider provider = const DefaultRandomProvider(),
}) {
  var alphaLength = randomBetween(0, length, provider: provider);
  var numericLength = length - alphaLength;
  var alpha = randomAlpha(alphaLength, provider: provider);
  var numeric = randomNumeric(numericLength, provider: provider);
  return randomMerge(alpha, numeric);
}

/// Merge [a] with [b] and shuffle.
String randomMerge(String a, String b) {
  var mergedCodeUnits = List.from('$a$b'.codeUnits);
  mergedCodeUnits.shuffle();
  return String.fromCharCodes(mergedCodeUnits.cast<int>());
}

/// ProviderError thrown when a [Provider] provides a value
/// outside the expected [0, 1) range.
class ProviderError implements Exception {
  final double value;

  ProviderError(this.value);

  @override
  String toString() => 'nextDouble() = $value, only [0, 1) expected';
}

String randomEmail() {
  // Generate a random username
  // You can customize the length and characters as needed
  String username = randomAlphaNumeric(10).toLowerCase();

  // List of possible domains
  List<String> domains = [
    'gmail.com',
    'yahoo.com',
    'outlook.com',
    'protonmail.com',
    'icloud.com',
  ];

  // Select a random domain from the list
  final random = Random();
  String domain = domains[random.nextInt(domains.length)];

  // Combine username and domain
  return '$username@$domain';
}

String? randomMobileNumber() {


  final Random random = Random();

  // Common mobile prefixes in Yemen (MTN, Sabafon, Y, Yemen Mobile)
  const List<String> prefixes = ['77', '78', '73', '71', '70'];

  // 1. Select a random prefix
  final String prefix = prefixes[random.nextInt(prefixes.length)];

  // 2. Generate the remaining 7 digits
  // To ensure it's always 7 digits, we generate a number between 1,000,000 and 9,999,999
  final int restOfNumber =
      1000000 + random.nextInt(9000000); // Ensures a 7-digit number

  // 3. Combine them into a full number
  return '$prefix${restOfNumber.toString()}';
}

String? randomWebsite() {

  // if(kDebugMode)return null;


  final Random random = Random();

  // Common Top-Level Domains (TLDs)
  const List<String> tlds = ['.com', '.org', '.net', '.io', '.dev', '.co'];

  // 1. Generate a random domain name (e.g., 8 characters long)
  final String domainName = randomString(8);

  // 2. Select a random TLD
  final String tld = tlds[random.nextInt(tlds.length)];

  // 3. Combine into a full URL
  return 'https://$domainName$tld';
}


/// Generates a random date and returns it as a formatted String.
///
/// [start]: The optional start date. Defaults to the Unix epoch.
/// [end]: The optional end date. Defaults to the current time.
/// [formatter]: The optional [DateFormat] to format the output.
/// Defaults to ISO 8601 format.
String randomFormattedDate({
  DateTime? start,
  DateFormat? formatter,
  DateTime? end,
}) {
  // Use provided dates or defaults.
  final effectiveStart = start ?? DateTime(1970, 1, 1);
  final effectiveEnd = end ?? DateTime.now();

  // Calculate the range and generate a random offset.
  final range = effectiveEnd.millisecondsSinceEpoch - effectiveStart.millisecondsSinceEpoch;
  final randomMillisOffset = Random().nextInt(range);
  final randomMillis = effectiveStart.millisecondsSinceEpoch + randomMillisOffset;

  final randomDate = DateTime.fromMillisecondsSinceEpoch(randomMillis);

  // Format the date using the provided formatter or default to ISO 8601.
  if (formatter != null) {
    return formatter.format(randomDate);
  } else {
    return randomDate.toIso8601String();
  }
}