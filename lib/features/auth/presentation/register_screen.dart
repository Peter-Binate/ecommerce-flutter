import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute l'état d'authentification
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);
    
    // Écouteur pour afficher les erreurs dans une SnackBar
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
      appBar: AppBar(title: const Text("S'inscrire")),
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
              // Le bouton est désactivé pendant le chargement
              onPressed: authState.isLoading
                  ? null
                  : () {
                      // On se contente d'appeler la méthode de notre contrôleur
                      authNotifier.register(
                        emailController.text.trim(),
                        passwordController.text,
                      );
                    },
              child: authState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Créer le compte"),
            ),
            TextButton(
              onPressed: authState.isLoading ? null : () => context.go('/login'),
              child: const Text('Déjà un compte ? Se connecter'),
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

// /// Écran d'inscription Email/Password minimal
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//   String? errorMessage;

//   Future<void> _register(BuildContext context, WidgetRef ref) async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });
//     await ref.read(authControllerProvider.notifier).register(
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
//       appBar: AppBar(title: const Text("S'inscrire")),
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
//               onPressed: isLoading ? null : () => _register(context, ref),
//               child: isLoading
//                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                   : const Text("Créer le compte"),
//             ),
//             TextButton(
//               onPressed: () => context.go('/login'),
//               child: const Text('Déjà un compte ? Se connecter'),
//             ),
//           ],
//         );
//         }),
//       ),
//     );
//   }
// }


