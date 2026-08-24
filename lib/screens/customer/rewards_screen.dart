import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CustRewardsScreen extends StatelessWidget {
  final void Function(String screen, {String? param}) nav;
  const CustRewardsScreen({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pts = appState.rewardPoints;
    final tier = appState.rewardTier;
    final next = appState.nextTierPoints;
    final progress = tier == 'Silver' ? pts / 500 : tier == 'Gold' ? (pts - 500) / 500 : 1.0;

    final tierColor = switch (tier) {
      'Gold' => const Color(0xFFD97706),
      'Platinum' => const Color(0xFF7C3AED),
      _ => const Color(0xFF6B7280),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top App Bar with Back Button
        Row(
          children: [
            IconButton(
              onPressed: () => nav('home'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            const SizedBox(width: 4),
            const Text('Rewards 🎁',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 12),
        // Points card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tierColor, tierColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(_tierEmoji(tier), style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 8),
                Text(tier, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 6),
              Text('$pts', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, height: 1)),
              const Text('Reward Points', style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              if (next > 0) ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Next tier in $next pts',
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('${_nextTier(tier)} →',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ] else
                const Text('🏆 Maximum Tier Achieved!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),

        const SizedBox(height: 24),
        // How to earn
        const Text('How to Earn Points',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        _EarnCard(icon: '🛒', title: 'Place an Order', desc: 'Earn 5% of your order value as points', pts: '+5%'),
        _EarnCard(icon: '⭐', title: 'Rate Your Order', desc: 'Rate and review your delivery', pts: '+25'),
        _EarnCard(icon: '👥', title: 'Refer a Friend', desc: 'Earn bonus when a friend places first order', pts: '+100'),
        _EarnCard(icon: '🎂', title: 'Birthday Bonus', desc: 'Special bonus points on your birthday', pts: '+200'),

        const SizedBox(height: 24),
        const Text('How to Redeem',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandRedBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text('💡', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('Redeem Points',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.brandRedDark)),
              ]),
              const SizedBox(height: 8),
              const Text('Every 100 points = ₹1 discount at checkout.',
                  style: TextStyle(color: AppColors.gray600, fontSize: 13, height: 1.5)),
              const Text('Minimum 500 points required to redeem.',
                  style: TextStyle(color: AppColors.gray500, fontSize: 11)),
              const SizedBox(height: 12),
              if (pts >= 100) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      appState.toggleRewardRedemption(true);
                      showAppToast(context, '🎉 Points applied! Redirecting to cart...');
                      nav('cart');
                    },
                    child: Text('Redeem $pts pts · Save ₹${(pts / 100).floor() * 10}'),
                  ),
                ),
              ] else
                Text('Earn ${100 - pts} more points to start redeeming.',
                    style: const TextStyle(color: AppColors.gray500, fontSize: 12)),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text('Reward History',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 10),
        ...context.read<AppState>().orders.where((o) => o.points > 0).map((o) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray100),
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          child: Row(children: [
            const Icon(Icons.stars_rounded, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(o.date, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
              ]),
            ),
            Text('+${o.points} pts',
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
          ]),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  String _tierEmoji(String tier) => switch (tier) {
    'Gold' => '🥇',
    'Platinum' => '💎',
    _ => '🥈',
  };

  String _nextTier(String tier) => switch (tier) {
    'Silver' => 'Gold',
    'Gold' => 'Platinum',
    _ => '',
  };
}

class _EarnCard extends StatelessWidget {
  final String icon, title, desc, pts;
  const _EarnCard({required this.icon, required this.title, required this.desc, required this.pts});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.base),
      boxShadow: AppShadows.subtle,
      border: Border.all(color: AppColors.gray100),
    ),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          Text(desc, style: const TextStyle(color: AppColors.gray400, fontSize: 11.5)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(pts,
            style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    ]),
  );
}
