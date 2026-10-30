
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _favoriteController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = context.read<UserProvider>().user;
    _nameController.text = user.name;
    _emailController.text = user.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProvider>();

    final error = await provider.validateProfile(
      _nameController.text,
      _emailController.text,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    await provider.saveProfile(
      _nameController.text.trim(),
      _emailController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan'),
      ),
    );
  }

  Future<void> _addFavorite() async {
    final value = _favoriteController.text.trim();

    if (value.isEmpty) return;

    await context.read<UserProvider>().addFavorite(value);
    _favoriteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await context.read<UserProvider>().logout();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      child: Icon(
                        Icons.person,
                        size: 55,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Simpan Profil'),
                      ),
                    ),

                    const Divider(height: 32),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Daftar Favorit / Hobi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _favoriteController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan hobi',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addFavorite,
                        ),
                      ),
                      onSubmitted: (_) => _addFavorite(),
                    ),

                    const SizedBox(height: 12),

                    for (final item in provider.favorites)
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          title: Text(item),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            tooltip: 'Hapus favorit',
                            onPressed: () {
                              context
                                  .read<UserProvider>()
                                  .removeFavorite(item);
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    const Text(
                      'Catatan keamanan: jangan menyimpan password di SharedPreferences.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
