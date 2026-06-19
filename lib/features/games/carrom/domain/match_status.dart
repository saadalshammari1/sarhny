/// حالة post-game لـ match — تشمل الكشف المتبادل وهوية الخصم لو كلاهما اختار reveal.
///
/// Field names mirror the FastAPI response from
/// `GET /api/v1/carrom/match/{match_id}` byte-for-byte; do NOT rename without
/// coordinating with `app/api/carrom_api.py::get_match`.
class CarromOpponentIdentity {
  const CarromOpponentIdentity({
    required this.username,
    required this.displayName,
    this.avatarPath,
  });
  final String username;
  final String displayName;
  /// Relative storage path (e.g. `users/abc.jpg`). Caller composes the
  /// CDN URL using the standard avatar helper.
  final String? avatarPath;

  factory CarromOpponentIdentity.fromJson(Map<String, dynamic> j) =>
      CarromOpponentIdentity(
        username: '${j['username']}',
        displayName: '${j['display_name']}',
        avatarPath: j['avatar_path']?.toString(),
      );
}

class CarromMatchStatus {
  const CarromMatchStatus({
    required this.matchId,
    required this.status,
    required this.winnerId,
    required this.pot,
    required this.yourRole,
    required this.mutualReveal,
    this.myReveal,
    this.opponentReveal,
    this.opponent,
    this.endedAt,
  });

  final int matchId;
  /// `finished` | `abandoned` | `playing` | `waiting`
  final String status;
  final int? winnerId;
  final int pot;
  /// `'a'` or `'b'` from the caller's perspective.
  final String yourRole;
  /// Both players selected `reveal`. The only condition under which
  /// `opponent` is non-null.
  final bool mutualReveal;
  /// `'reveal'`, `'hide'`, or null (no choice yet).
  final String? myReveal;
  final String? opponentReveal;
  final CarromOpponentIdentity? opponent;
  /// ISO-ish timestamp the server sends (`YYYY-MM-DD HH:MM:SS`).
  final String? endedAt;

  factory CarromMatchStatus.fromJson(Map<String, dynamic> j) {
    final opp = j['opponent'];
    return CarromMatchStatus(
      matchId: (j['match_id'] as num).toInt(),
      status: '${j['status']}',
      winnerId: (j['winner_id'] as num?)?.toInt(),
      pot: (j['pot'] as num?)?.toInt() ?? 0,
      yourRole: '${j['your_role'] ?? 'a'}',
      mutualReveal: j['mutual_reveal'] == true,
      myReveal: j['my_reveal']?.toString(),
      opponentReveal: j['opponent_reveal']?.toString(),
      opponent: (opp is Map)
          ? CarromOpponentIdentity.fromJson(opp.cast<String, dynamic>())
          : null,
      endedAt: j['ended_at']?.toString(),
    );
  }
}

/// قيد دفتر المحفظة — نقاط داخلة / خارجة. Mirrors the FastAPI response from
/// `GET /api/v1/carrom/wallet/history`.
class CarromLedgerEntry {
  const CarromLedgerEntry({
    required this.id,
    required this.delta,
    required this.reason,
    required this.balanceAfter,
    this.ts,
    this.refId,
  });

  final int id;
  /// +ve = اكتساب، -ve = صرف.
  final int delta;
  /// e.g. `welcome`, `match_entry`, `match_win`, `inbox_received`,
  /// `ad_rewarded`, `hide_identity`, `auto_topup`, `admin_grant`,
  /// `admin_clawback`, `skip_question`.
  final String reason;
  final int balanceAfter;
  /// Server-side timestamp string (no parsing — UI formats locally).
  final String? ts;
  /// e.g. `match:42`, `inbox:128`, `ad:tx_xyz`.
  final String? refId;

  factory CarromLedgerEntry.fromJson(Map<String, dynamic> j) =>
      CarromLedgerEntry(
        id: (j['id'] as num?)?.toInt() ?? 0,
        delta: (j['delta'] as num?)?.toInt() ?? 0,
        reason: '${j['reason'] ?? 'unknown'}',
        balanceAfter: (j['balance_after'] as num?)?.toInt() ?? 0,
        ts: j['ts']?.toString(),
        refId: j['ref_id']?.toString(),
      );

  /// نص عربي قصير للعرض.
  String get arabicLabel {
    switch (reason) {
      case 'match_win':
        return 'فوز بمباراة';
      case 'match_entry':
        return 'رسم دخول مباراة';
      case 'ad_rewarded':
        return 'مشاهدة إعلان';
      case 'inbox_received':
        return 'استقبال رسالة صراحة';
      case 'hide_identity':
        return 'إخفاء الهوية';
      case 'welcome':
        return 'هدية ترحيب';
      case 'auto_topup':
        return 'تعبئة تلقائية';
      case 'skip_question':
        return 'تخطّي سؤال';
      case 'admin_grant':
        return 'منحة دعم';
      case 'admin_clawback':
        return 'استرداد إداري';
      default:
        return 'حركة على المحفظة';
    }
  }
}

/// Outcome of POST /api/v1/games/ad/grant.
class AdGrantResult {
  const AdGrantResult({
    required this.credited,
    required this.balance,
    required this.remainingToday,
    this.adToken,
  });
  final int credited;
  final int balance;
  final int remainingToday;
  /// AdMob transaction_id of the grant — passed back so downstream
  /// endpoints (e.g. /xo/{id}/abstain) can attest the ad happened.
  final String? adToken;
}

/// Outcome of GET /api/v1/games/ad/quota.
class AdQuotaInfo {
  const AdQuotaInfo({
    required this.usedToday,
    required this.dailyCap,
    required this.remaining,
  });
  final int usedToday;
  final int dailyCap;
  final int remaining;
}
