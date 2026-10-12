import 'package:flutter/material.dart';
import 'package:symptomm/app_state.dart';

const blue = Color(0xFF327FB2);
const teal = Color(0xFF32ACCC);
bool get isDarkMode => darkMode.value;
Color get ink => isDarkMode ? const Color(0xFFEAF2F8) : const Color(0xFF23384E);
Color get canvas =>
    isDarkMode ? const Color(0xFF182633) : const Color(0xFFEAF1F8);
Color get panel =>
    isDarkMode ? const Color(0xFF223544) : const Color(0xFFFFFFFF);
Color get subtleSurface =>
    isDarkMode ? const Color(0xFF2B4050) : const Color(0xFFF0F5F5);
Color get mutedInk =>
    isDarkMode ? const Color(0xFFA7BBCB) : const Color(0xFF637B91);
Color get outlineTone =>
    isDarkMode ? const Color(0xFF3B5264) : const Color(0xFFDCE5EF);

BoxDecoration card({Color? color, Color? border, double radius = 22}) =>
    BoxDecoration(
      color: color ?? panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border ?? outlineTone,
        width: border == null ? 1 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: .22)
              : const Color(0xFFFFFFFF),
          offset: const Offset(-5, -5),
          blurRadius: 12,
        ),
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: .28)
              : const Color(0xFFC9D5E3),
          offset: const Offset(5, 5),
          blurRadius: 12,
        ),
      ],
    );

BoxDecoration insetSurface({double radius = 18}) => BoxDecoration(
      color: isDarkMode ? const Color(0xFF1C2D3B) : canvas,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: outlineTone),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: .3)
              : const Color(0xFFC9D5E3),
          offset: const Offset(3, 3),
          blurRadius: 7,
        ),
        BoxShadow(
          color: isDarkMode ? const Color(0xFF2B4050) : const Color(0xFFFFFFFF),
          offset: const Offset(-3, -3),
          blurRadius: 7,
        ),
      ],
    );

class Shell extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  const Shell({
    super.key,
    this.title,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: canvas,
        floatingActionButton: floatingActionButton,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [const Color(0xFF182633), const Color(0xFF1D2D3B)]
                  : [const Color(0xFFEAF1F8), const Color(0xFFF1F6FB)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      if (title != null || actions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: card(radius: 18),
                            child: Row(
                              children: [
                                if (title != null)
                                  Expanded(
                                    child: Text(
                                      title!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: ink,
                                      ),
                                    ),
                                  )
                                else
                                  const Spacer(),
                                ...actions,
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
                        ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8 + MediaQuery.paddingOf(context).bottom,
                height: 44,
                child: Center(
                  child: Material(
                    color: panel,
                    borderRadius: BorderRadius.circular(16),
                    child: IconButton(
                      tooltip: 'Home',
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      icon: const Icon(Icons.home_rounded),
                      color: blue,
                      style: IconButton.styleFrom(
                        backgroundColor: panel,
                        minimumSize: const Size(52, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class GBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GBtn(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? .5 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF35B8D8), Color(0xFF2D9FC4)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFB9D3E3),
                  offset: Offset(4, 5),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: Color(0xFFFFFFFF),
                  offset: Offset(-3, -3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

const disclaimer =
    'Not a diagnostic tool. This application suggests relevant medical specialties based on symptoms; it does not diagnose conditions.';
const emergency =
    'EMERGENCY ADVISORY: For severe symptoms like chest pain, trouble breathing, or sudden numbness, call emergency services immediately.';

Widget emergencyBox() => Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF452D34) : const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF69414A) : const Color(0xFFF6C9CC),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: .2)
                : const Color(0xFFFFFFFF),
            offset: const Offset(-3, -3),
            blurRadius: 8,
          ),
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: .25)
                : const Color(0xFFE7CBD0),
            offset: const Offset(3, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFCC4650), size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              emergency,
              style: TextStyle(fontSize: 12, color: ink, height: 1.4),
            ),
          ),
        ],
      ),
    );

void snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
