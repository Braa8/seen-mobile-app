import 'package:flutter/material.dart';

import '../../core/services/seen_repository.dart';
import '../../core/services/offline_library.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/seen_theme.dart';
import '../../core/widgets/seen_brand.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../puzzle/daily_puzzle_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.repository,
    required this.offline,
  });

  final SeenRepository repository;
  final OfflineLibrary offline;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _signingOut = false;

  Future<void> _signIn() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Future<void> _signOut() async {
    if (_signingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'هل تريد تسجيل الخروج من حسابك على هذا الجهاز؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _signingOut = true);

    try {
      await SessionService.instance.signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تسجيل الخروج. حاول مجدداً.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          repository: widget.repository,
        ),
      ),
    );
  }

  void _openPuzzle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyPuzzleScreen(),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'سين',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SeenColors.tealDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'س',
            style: TextStyle(
              color: SeenColors.gold,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      children: const [
        Text(
          'سين تجربة صحفية عربية للقراءة الواعية، '
          'تمنح الخبر سياقه وتمنح القارئ مساحة للتفكير.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;

    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final signedIn = session.isSignedIn;
        final displayName = session.displayName?.trim();
        final email = session.email?.trim();

        final name = signedIn &&
                displayName != null &&
                displayName.isNotEmpty
            ? displayName
            : 'قارئ سين';

        final accountSubtitle = signedIn &&
                email != null &&
                email.isNotEmpty
            ? email
            : signedIn
                ? 'حسابك في سين'
                : 'سجّل الدخول لمزامنة مفضّلتك';

        final avatarText = signedIn &&
                displayName != null &&
                displayName.isNotEmpty
            ? displayName.characters.first
            : 'س';

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              const SeenBrand(),

              const SizedBox(height: 30),

              Text(
                'مساحتك في سين',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 8),

              Text(
                'كل ما تحتاجه لتجعل القراءة أقرب إليك.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SeenColors.muted,
                      height: 1.6,
                    ),
              ),

              const SizedBox(height: 22),

              _AccountCard(
                name: name,
                subtitle: accountSubtitle,
                avatarText: avatarText,
                signedIn: signedIn,
              ),

              const SizedBox(height: 28),

              const _SectionHeading(
                title: 'حسابك',
                subtitle: 'إدارة الوصول إلى حسابك',
              ),

              const SizedBox(height: 10),

              if (!signedIn)
                _ProfileTile(
                  icon: Icons.login_rounded,
                  title: 'تسجيل الدخول',
                  subtitle: 'تابع القراءة من حسابك الحالي',
                  onTap: _signIn,
                )
              else
                _ProfileTile(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  subtitle: 'إنهاء الجلسة على هذا الجهاز',
                  trailing: _signingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                  onTap: _signingOut ? null : _signOut,
                ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'اكتشف',
                subtitle: 'مساحة إضافية للقراءة والتفكير',
              ),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.notifications_none_rounded,
                title: 'الإشعارات',
                subtitle: 'تابع آخر التحديثات',
                onTap: _openNotifications,
              ),

              _ProfileTile(
                icon: Icons.grid_4x4_rounded,
                title: 'لغز اليوم',
                subtitle: 'استراحة قصيرة للعقل',
                onTap: _openPuzzle,
              ),

              const SizedBox(height: 24),

              const _SectionHeading(
                title: 'عن التطبيق',
                subtitle: 'فكرتنا في القراءة الواعية',
              ),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.auto_stories_outlined,
                title: 'عن سين',
                subtitle: 'صحافة تُقرأ بعمق',
                onTap: _showAbout,
              ),

              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 3,
                      decoration: BoxDecoration(
                        color: SeenColors.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'صُمّم للقراءة بهدوء.',
                      style: TextStyle(
                        color: SeenColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'سين · 1.0.0',
                      style: TextStyle(
                        color: SeenColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.subtitle,
    required this.avatarText,
    required this.signedIn,
  });

  final String name;
  final String subtitle;
  final String avatarText;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeenColors.tealDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: SeenColors.gold,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Center(
              child: Text(
                avatarText,
                style: const TextStyle(
                  color: SeenColors.ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD4E1DC),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: signedIn
                              ? const Color(0xFF9BD4B0)
                              : SeenColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        signedIn ? 'حساب متصل' : 'وضع الزائر',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SeenColors.muted,
              ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 7,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: SeenColors.teal.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: SeenColors.teal,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: SeenColors.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_left_rounded,
              color: SeenColors.muted,
            ),
        onTap: onTap,
      ),
    );
  }
}