import 'dart:math';
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
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid ambiguous chars
    final rnd = Random.secure();
    final code = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length)))
    );
    
    // Clear old pending pairs first
    await _supabase.from('pairs')
      .delete()
      .eq('user_id_1', user.id)
      .eq('status', 'pending');

    await _supabase.from('pairs').insert({
      'user_id_1': user.id,
      'invite_code': code,
      'status': 'pending',
      'created_at': DateTime.now().toUtc().toIso8601String(),
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

    if (response == null) {
      throw Exception('Invalid or expired code');
    }

    if (response['user_id_1'] == user.id) {
      throw Exception('You cannot pair with yourself');
    }

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

    // Use upsert to prevent race conditions and simplify logic
    // We assume 'user_id' has a unique constraint in the DB or we handle it via RLS
    await _supabase.from('pair_sessions').upsert({
      'user_id': user.id,
      'status': status,
      'last_active_at': DateTime.now().toIso8601String(),
      'started_at': status == 'breathing' ? DateTime.now().toIso8601String() : null,
    }, onConflict: 'user_id');
  }
  
  // Stream partner's presence
  Stream<Map<String, dynamic>?> partnerPresenceStream(String partnerId) {
    return _supabase.from('pair_sessions')
      .stream(primaryKey: ['id'])
      .eq('user_id', partnerId)
      .map((events) => events.isNotEmpty ? events.first : null);
  }
}
