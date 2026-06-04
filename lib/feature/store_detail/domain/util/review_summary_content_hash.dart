import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_snippet_input.dart';
import 'package:capstone_2026/feature/store_detail/domain/util/review_summary_snippet_normalizer.dart';

String computeReviewSummaryContentHash(List<ReviewSnippetInput> snippets) {
  final parts = snippets
      .map((snippet) {
        final rating = formatRatingForHash(snippet.rating);
        final visitPurpose = snippet.visitPurpose ?? '';
        return '${snippet.sourceKey}|$rating|$visitPurpose|${snippet.text}';
      })
      .toList()
    ..sort();
  final digest = sha256.convert(utf8.encode(parts.join('\n')));
  return digest.toString();
}
