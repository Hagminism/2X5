import 'package:capstone_2026/core/data/data_source/owner_verification/owner_verification_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerVerificationDataSourceImpl implements OwnerVerificationDataSource {
  final SupabaseClient _supabaseClient;

  const OwnerVerificationDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<String?> findLatestApprovedBusinessNumberByOwnerId(String ownerId) async {
    final json = await _supabaseClient
        .from('owner_verifications')
        .select('business_number')
        .eq('owner_id', ownerId)
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (json == null) {
      return null;
    }

    return (json['business_number'] as String?)?.trim();
  }
}
