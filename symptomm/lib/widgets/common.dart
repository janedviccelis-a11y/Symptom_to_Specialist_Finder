import 'package:flutter/material.dart';

const blue = Color(0xFF2F6AA3), teal = Color(0xFF4FA58F), ink = Color(0xFF12202B);

BoxDecoration card({Color? color, Color? border}) => BoxDecoration(
  color: color ?? Colors.white.withValues(alpha: .92),
  borderRadius: BorderRadius.circular(14),
  border: Border.all(
    color: border ?? const Color(0xFFB9D7DC),
    width: border == null ? 1 : 2,
  ),
);

class Shell extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget> actions;

  const Shell({super.key, this.title, required this.child, this.actions = const []});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFCDEBEE), Color(0xFFF3FAFB)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const SizedBox(width: 16),
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    ...actions,
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(child: child),
              ],
            ),
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
              gradient: const LinearGradient(colors: [blue, teal]),
              borderRadius: BorderRadius.circular(28),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: onTap,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBDDDD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFD33B3B), size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              emergency,
              style: TextStyle(fontSize: 12.5, color: ink),
            ),
          ),
        ],
      ),
    );

void snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
