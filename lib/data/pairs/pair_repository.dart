import 'package:supabase_flutter/supabase_flutter.dart';

class PairRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // PAIR MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Creates a new pair with a random 6-digit invite code.
  Future<String> createInvite() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Generate random 6 character code (uppercase alphanumeric)
    // Simple implementation:
    final code = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);
    
    // Check if user already has a pair?
    // Ideally we clear old pending pairs first
    await _supabase.from('pairs')
      .delete()
      .eq('user_id_1', user.id)
      .eq('status', 'pending');

    await _supabase.from('pairs').insert({
      'user_id_1': user.id,
      'invite_code': code,
      'status': 'pending',
    });

    return code;
  }

  /// Joins a pair using an invite code.
  Future<void> joinPair(String code) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Find the pair
    final response = await _supabase.from('pairs')
      .select()
      .eq('invite_code', code)
      .eq('status', 'pending')
      .maybeSingle();

    if (response == null) throw Exception('Invalid or expired code');

    final pairId = response['id'];
    
    // Update the pair
    await _supabase.from('pairs').update({
      'user_id_2': user.id,
      'status': 'active',
      'invite_code': null, // Clear code usage
    }).eq('id', pairId);
  }

  /// Gets the current active pair for the user.
  Future<Map<String, dynamic>?> getActivePair() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase.from('pairs')
      .select('*, partner_1:user_id_1(username, avatar_url), partner_2:user_id_2(username, avatar_url)')
      .or('user_id_1.eq.${user.id},user_id_2.eq.${user.id}')
      .eq('status', 'active')
      .maybeSingle();
      
    return response;
  }

  /// Leaves/Deletes the current pair.
  Future<void> leavePair() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('pairs')
      .delete()
      .or('user_id_1.eq.${user.id},user_id_2.eq.${user.id}');
  }

  // ---------------------------------------------------------------------------
  // MESSAGING
  // ---------------------------------------------------------------------------

  Future<void> sendMessage(String pairId, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('pair_messages').insert({
      'pair_id': pairId,
      'sender_id': user.id,
      'content': content,
    });
  }

  Stream<List<Map<String, dynamic>>> messagesStream(String pairId) {
    return _supabase.from('pair_messages')
      .stream(primaryKey: ['id'])
      .eq('pair_id', pairId)
      .order('created_at', ascending: false)
      .limit(50);
  }

  // ---------------------------------------------------------------------------
  // PRESENCE / SESSION STATUS
  // ---------------------------------------------------------------------------

  Future<void> updatePresence(String status) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Upsert session
    // Since we don't have a unique constraint on user_id in the schema specifically for upsert without ID,
    // we rely on RLS or simple logic. Ideally create table pair_sessions (user_id PK).
    // Let's assume user_id is unique enough or we query first.
    // Actually, 'pair_sessions' schema had 'id' PK.
    // Let's check if we have a session.
    
    final existing = await _supabase.from('pair_sessions')
      .select('id')
      .eq('user_id', user.id)
      .maybeSingle();
      
    if (existing != null) {
      await _supabase.from('pair_sessions').update({
        'status': status,
        'last_active_at': DateTime.now().toIso8601String(),
        'started_at': status == 'breathing' ? DateTime.now().toIso8601String() : null,
      }).eq('id', existing['id']);
    } else {
      await _supabase.from('pair_sessions').insert({
        'user_id': user.id,
        'status': status,
        'started_at': status == 'breathing' ? DateTime.now().toIso8601String() : null,
      });
    }
  }
  
  // Stream partner's presence
  Stream<Map<String, dynamic>?> partnerPresenceStream(String partnerId) {
    return _supabase.from('pair_sessions')
      .stream(primaryKey: ['id'])
      .eq('user_id', partnerId)
      .map((events) => events.isNotEmpty ? events.first : null);
  }
}
