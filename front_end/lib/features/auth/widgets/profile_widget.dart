import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class ProfileWidget extends ConsumerWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(authStateNotifierProvider);
    
    return userAsyncValue.when(
      data: (UserModel? user) {
        if (user == null) {
          return const Center(
            child: Text('Not signed in'),
          );
        }
        
        return _buildProfileContent(context, ref, user);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
  
  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoURL != null 
                ? NetworkImage(user.photoURL!) 
                : null,
            child: user.photoURL == null 
                ? const Icon(Icons.person, size: 50) 
                : null,
          ),
          const SizedBox(height: 16),
          
          // Display name
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Email
          if (user.email != null)
            Text(
              user.email!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 24),
          
          // Sign out button
          ElevatedButton(
            onPressed: () {
              ref.read(authStateNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
} 