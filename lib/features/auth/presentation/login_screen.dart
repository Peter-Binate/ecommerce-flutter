import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute les changements d'état pour reconstruire le widget (ex: afficher l'erreur)
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);

    // On peut aussi écouter pour des actions uniques comme afficher une SnackBar
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // On désactive le bouton si l'état est en chargement
              onPressed: authState.isLoading
                  ? null
                  : () {
                      // On appelle simplement la méthode, GoRouter s'occupera de la redirection
                      authNotifier.signIn(
                        emailController.text.trim(),
                        passwordController.text,
                      );
                    },
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Se connecter'),
            ),
            TextButton(
              onPressed: authState.isLoading ? null : () => context.go('/register'),
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../auth/application/auth_controller.dart';

// /// Écran de connexion Email/Password minimal (MVP)
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//   String? errorMessage;

//   Future<void> _login(BuildContext context, WidgetRef ref) async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });
//     await ref.read(authControllerProvider.notifier).signIn(
//           emailController.text.trim(),
//           passwordController.text,
//         );
//     final err = ref.read(authControllerProvider).error;
//     if (mounted) {
//       setState(() => isLoading = false);
//       if (err != null) {
//         setState(() => errorMessage = err);
//       } else {
//         if (mounted) context.go('/catalog');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Consumer(builder: (context, ref, _) {
//           return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Mot de passe'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 12),
//             if (errorMessage != null)
//               Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: isLoading ? null : () => _login(context, ref),
//               child: isLoading
//                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                   : const Text('Se connecter'),
//             ),
//             TextButton(
//               onPressed: () => context.go('/register'),
//               child: const Text("S'inscrire"),
//             ),
//           ],
//         );
//         }),
//       ),
//     );
//   }
// }


