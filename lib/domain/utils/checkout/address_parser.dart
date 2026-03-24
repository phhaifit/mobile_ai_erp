/// Result of AI address parsing
class AddressParseResult {
  const AddressParseResult({
    required this.success,
    this.address,
    this.confidence = 0.0,
    this.suggestions = const [],
    this.errorMessage,
  });

  /// Whether parsing was successful
  final bool success;

  /// Parsed address components
  final ParsedAddress? address;

  /// Confidence score (0.0 to 1.0)
  final double confidence;

  /// Alternative suggestions if confidence is low
  final List<ParsedAddress> suggestions;

  /// Error message if parsing failed
  final String? errorMessage;

  /// Check if the result needs user confirmation
  bool get needsConfirmation => confidence < 0.8 && suggestions.isNotEmpty;
}

/// Parsed address components from AI parsing
class ParsedAddress {
  const ParsedAddress({
    this.street,
    this.city,
    this.state,
    this.stateCode,
    this.postalCode,
    this.country,
    this.countryCode,
    this.building,
    this.unit,
    this.recipientName,
    this.phone,
  });

  final String? street;
  final String? city;
  final String? state;
  final String? stateCode;
  final String? postalCode;
  final String? country;
  final String? countryCode;
  final String? building;
  final String? unit;
  final String? recipientName;
  final String? phone;

  /// Check if address has minimum required fields
  bool get isValid => street != null && city != null;

  /// Get formatted address string
  String get formatted {
    final parts = <String?>[
      street,
      city,
      state,
      postalCode,
      country,
    ].whereType<String>().toList();
    return parts.join(', ');
  }

  ParsedAddress copyWith({
    String? street,
    String? city,
    String? state,
    String? stateCode,
    String? postalCode,
    String? country,
    String? countryCode,
    String? building,
    String? unit,
    String? recipientName,
    String? phone,
  }) {
    return ParsedAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      building: building ?? this.building,
      unit: unit ?? this.unit,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
    );
  }
}

/// AI-powered address parser utility
/// Simulates smart address parsing functionality
class AddressParser {
  /// Common address patterns for parsing
  static final RegExp _streetPattern = RegExp(
    r'^(\d+)\s+(.+?)(?:\s+(?:apt|apartment|unit|suite|ste|#)\s*(\w+))?$',
    caseSensitive: false,
  );

  static final RegExp _postalCodePattern = RegExp(
    r'\b(\d{5}(?:-\d{4})?|[A-Z]\d[A-Z]\s*\d[A-Z]\d)\b',
  );

  static final RegExp _phonePattern = RegExp(
    r'(\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4})',
  );

  /// Parse a raw address string into structured components
  static AddressParseResult parse(String rawAddress) {
    if (rawAddress.trim().isEmpty) {
      return const AddressParseResult(
        success: false,
        errorMessage: 'Address cannot be empty',
      );
    }

    // Clean up the input
    final cleaned = _cleanInput(rawAddress);

    // Split into parts
    final parts = cleaned.split(',').map((p) => p.trim()).toList();

    if (parts.length < 2) {
      return const AddressParseResult(
        success: false,
        errorMessage: 'Address is too short. Please provide more details.',
      );
    }

    // Try to extract components
    final parsed = _extractComponents(parts, cleaned);

    if (!parsed.isValid) {
      return AddressParseResult(
        success: false,
        errorMessage: 'Could not parse address. Please check the format.',
      );
    }

    // Calculate confidence based on completeness
    final confidence = _calculateConfidence(parsed);

    // Generate suggestions if confidence is low
    final suggestions = confidence < 0.8
        ? _generateSuggestions(parts, cleaned)
        : <ParsedAddress>[];

    return AddressParseResult(
      success: true,
      address: parsed,
      confidence: confidence,
      suggestions: suggestions,
    );
  }

  /// Clean and normalize input
  static String _cleanInput(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[;|]'), ',')
        .trim();
  }

  /// Extract address components from parts
  static ParsedAddress _extractComponents(List<String> parts, String fullText) {
    String? street;
    String? city;
    String? state;
    String? stateCode;
    String? postalCode;
    String? country;
    String? countryCode;
    String? building;
    String? unit;
    String? recipientName;
    String? phone;

    // Extract phone number
    final phoneMatch = _phonePattern.firstMatch(fullText);
    if (phoneMatch != null) {
      phone = phoneMatch.group(1);
    }

    // Extract postal code
    final postalMatch = _postalCodePattern.firstMatch(fullText);
    if (postalMatch != null) {
      postalCode = postalMatch.group(1);
    }

    // Parse based on number of parts
    if (parts.isNotEmpty) {
      // First part is usually street address
      final firstPart = parts[0];

      // Check for unit/apartment
      final streetMatch = _streetPattern.firstMatch(firstPart);
      if (streetMatch != null) {
        street = '${streetMatch.group(1)} ${streetMatch.group(2)}';
        if (streetMatch.group(3) != null) {
          unit = streetMatch.group(3);
        }
      } else {
        street = firstPart;
      }
    }

    if (parts.length > 1) {
      city = parts[1];
    }

    if (parts.length > 2) {
      final statePart = parts[2].trim();
      // Check if it contains state code
      final stateCodeMatch = RegExp(r'\b([A-Z]{2})\b').firstMatch(statePart);
      if (stateCodeMatch != null) {
        stateCode = stateCodeMatch.group(1);
        state = _getStateName(stateCode!);
      } else {
        state = statePart;
        stateCode = _getStateCode(statePart);
      }
    }

    if (parts.length > 3) {
      country = parts[3];
      countryCode = _getCountryCode(country);
    } else {
      // Default to US if not specified
      country = 'United States';
      countryCode = 'US';
    }

    return ParsedAddress(
      street: street,
      city: city,
      state: state,
      stateCode: stateCode,
      postalCode: postalCode,
      country: country,
      countryCode: countryCode,
      building: building,
      unit: unit,
      recipientName: recipientName,
      phone: phone,
    );
  }

  /// Calculate confidence score
  static double _calculateConfidence(ParsedAddress address) {
    int score = 0;
    const maxScore = 8;

    if (address.street != null && address.street!.isNotEmpty) score++;
    if (address.city != null && address.city!.isNotEmpty) score++;
    if (address.state != null && address.state!.isNotEmpty) score++;
    if (address.postalCode != null && address.postalCode!.isNotEmpty) score++;
    if (address.country != null && address.country!.isNotEmpty) score++;
    if (address.countryCode != null) score++;
    if (address.unit != null && address.unit!.isNotEmpty) score++;
    if (address.phone != null && address.phone!.isNotEmpty) score++;

    return score / maxScore;
  }

  /// Generate alternative suggestions
  static List<ParsedAddress> _generateSuggestions(
    List<String> parts,
    String fullText,
  ) {
    // In a real implementation, this would use AI/ML to suggest alternatives
    // For now, return empty list
    return [];
  }

  /// Get state name from code
  static String _getStateName(String code) {
    const states = {
      'AL': 'Alabama',
      'AK': 'Alaska',
      'AZ': 'Arizona',
      'AR': 'Arkansas',
      'CA': 'California',
      'CO': 'Colorado',
      'CT': 'Connecticut',
      'DE': 'Delaware',
      'FL': 'Florida',
      'GA': 'Georgia',
      'HI': 'Hawaii',
      'ID': 'Idaho',
      'IL': 'Illinois',
      'IN': 'Indiana',
      'IA': 'Iowa',
      'KS': 'Kansas',
      'KY': 'Kentucky',
      'LA': 'Louisiana',
      'ME': 'Maine',
      'MD': 'Maryland',
      'MA': 'Massachusetts',
      'MI': 'Michigan',
      'MN': 'Minnesota',
      'MS': 'Mississippi',
      'MO': 'Missouri',
      'MT': 'Montana',
      'NE': 'Nebraska',
      'NV': 'Nevada',
      'NH': 'New Hampshire',
      'NJ': 'New Jersey',
      'NM': 'New Mexico',
      'NY': 'New York',
      'NC': 'North Carolina',
      'ND': 'North Dakota',
      'OH': 'Ohio',
      'OK': 'Oklahoma',
      'OR': 'Oregon',
      'PA': 'Pennsylvania',
      'RI': 'Rhode Island',
      'SC': 'South Carolina',
      'SD': 'South Dakota',
      'TN': 'Tennessee',
      'TX': 'Texas',
      'UT': 'Utah',
      'VT': 'Vermont',
      'VA': 'Virginia',
      'WA': 'Washington',
      'WV': 'West Virginia',
      'WI': 'Wisconsin',
      'WY': 'Wyoming',
    };
    return states[code.toUpperCase()] ?? code;
  }

  /// Get state code from name
  static String? _getStateCode(String name) {
    const codes = {
      'alabama': 'AL',
      'alaska': 'AK',
      'arizona': 'AZ',
      'arkansas': 'AR',
      'california': 'CA',
      'colorado': 'CO',
      'connecticut': 'CT',
      'delaware': 'DE',
      'florida': 'FL',
      'georgia': 'GA',
      'hawaii': 'HI',
      'idaho': 'ID',
      'illinois': 'IL',
      'indiana': 'IN',
      'iowa': 'IA',
      'kansas': 'KS',
      'kentucky': 'KY',
      'louisiana': 'LA',
      'maine': 'ME',
      'maryland': 'MD',
      'massachusetts': 'MA',
      'michigan': 'MI',
      'minnesota': 'MN',
      'mississippi': 'MS',
      'missouri': 'MO',
      'montana': 'MT',
      'nebraska': 'NE',
      'nevada': 'NV',
      'new hampshire': 'NH',
      'new jersey': 'NJ',
      'new mexico': 'NM',
      'new york': 'NY',
      'north carolina': 'NC',
      'north dakota': 'ND',
      'ohio': 'OH',
      'oklahoma': 'OK',
      'oregon': 'OR',
      'pennsylvania': 'PA',
      'rhode island': 'RI',
      'south carolina': 'SC',
      'south dakota': 'SD',
      'tennessee': 'TN',
      'texas': 'TX',
      'utah': 'UT',
      'vermont': 'VT',
      'virginia': 'VA',
      'washington': 'WA',
      'west virginia': 'WV',
      'wisconsin': 'WI',
      'wyoming': 'WY',
    };
    return codes[name.toLowerCase()];
  }

  /// Get country code from name
  static String _getCountryCode(String name) {
    const codes = {
      'united states': 'US',
      'usa': 'US',
      'us': 'US',
      'canada': 'CA',
      'united kingdom': 'GB',
      'uk': 'GB',
      'australia': 'AU',
      'germany': 'DE',
      'france': 'FR',
      'japan': 'JP',
      'china': 'CN',
      'vietnam': 'VN',
      'viet nam': 'VN',
    };
    return codes[name.toLowerCase()] ?? name.toUpperCase().substring(0, 2);
  }
}
