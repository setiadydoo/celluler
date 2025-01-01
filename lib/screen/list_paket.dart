import 'package:flutter/material.dart';
import 'package:provider_celuler/model/paket_data.dart';
import 'package:provider_celuler/model/user.dart';
import 'package:provider_celuler/screen/add_paket.dart';
import 'package:provider_celuler/screen/detail_paket.dart';
import 'package:provider_celuler/screen/edit_paket.dart';
import 'package:provider_celuler/screen/home.dart';
import 'package:provider_celuler/service/appwrite.dart';

class ListPaketScreen extends StatefulWidget {
  const ListPaketScreen({super.key});

  @override
  _ListPaketScreenState createState() => _ListPaketScreenState();
}

class _ListPaketScreenState extends State<ListPaketScreen> {
  final AppwriteService _appwriteService = AppwriteService();
  List<PaketData> _paketList = [];
  List<PaketData> _filteredPaketList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchUserData();
    _fetchPaketData();
    _searchController.addListener(_filterPaketList);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      UserModel? user = await _appwriteService.getCurrentUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaketData() async {
    try {
      final paketData = await _appwriteService.fetchPaketData();
      setState(() {
        _paketList = paketData;
        _filteredPaketList = paketData;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void _filterPaketList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPaketList = _paketList
          .where((paket) => paket.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white)),
        centerTitle: true,
        title: const Text(
          'Daftar Paket',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                _user!.name == "admin"
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddPaket()));
                          },
                          child: const Text("Tambah Paket"),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari Paket',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredPaketList.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada data paket.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredPaketList.length,
                          itemBuilder: (context, index) {
                            final paket = _filteredPaketList[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPaketScreen(paket: paket),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 6.0,
                                ),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Colors.red[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            paket.nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.red,
                                            ),
                                          ),
                                          _user!.name == "admin"
                                              ? Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditPaketScreen(
                                                                    paket:
                                                                        paket),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title: const Text(
                                                                          'Konfirmasi'),
                                                                      content:
                                                                          const Text(
                                                                              'Apakah Anda yakin ingin menghapus paket ini?'),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Batal'),
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text('Hapus'),
                                                                          onPressed:
                                                                              () async {
                                                                            AppwriteService().deletePaketData(paket.id);
                                                                            await _fetchPaketData();
                                                                            Navigator.pushReplacement(context,
                                                                                MaterialPageRoute(builder: (context) => const ListPaketScreen()));
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ));
                                                      },
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Harga: ${paket.harga}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        paket.deskripsi,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
