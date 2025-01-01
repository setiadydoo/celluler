
class PaketData {
  final String id;
  final String nama;
  final String harga;
  final String deskripsi;
  final String? gambar;
  final String? gambarId;

  PaketData({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    this.gambar,
    this.gambarId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '\$id': id,
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'gambarId': gambarId,
    };
  }

  factory PaketData.fromMap(Map<String, dynamic> map) {
    return PaketData(
      id: map['\$id'] as String,
      nama: map['nama'] as String,
      harga: map['harga'] as String,
      deskripsi: map['deskripsi'] as String,
      gambar: map['gambar'] as String?,
      gambarId: map['gambarId'] as String?,
    );
  }
}
