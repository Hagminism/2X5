enum ReviewSnippetSource {
  platform,
  naver,
  google,
}

class ReviewSnippetInput {
  const ReviewSnippetInput({
    required this.source,
    required this.text,
    this.rating,
    this.visitPurpose,
  });

  final ReviewSnippetSource source;
  final String text;
  final double? rating;
  final String? visitPurpose;

  String get sourceKey {
    return switch (source) {
      ReviewSnippetSource.platform => 'platform',
      ReviewSnippetSource.naver => 'naver',
      ReviewSnippetSource.google => 'google',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'source': sourceKey,
      'text': text,
      if (rating != null) 'rating': rating,
      if (visitPurpose != null && visitPurpose!.isNotEmpty)
        'visitPurpose': visitPurpose,
    };
  }
}
