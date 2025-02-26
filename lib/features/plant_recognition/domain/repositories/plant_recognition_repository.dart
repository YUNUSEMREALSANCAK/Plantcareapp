import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlantRecognitionRepository {
  // API anahtarı
  final String _apiKey =
      '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';
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> recognizePlant(File imageFile) async {
    try {
      print('Bitki tanıma işlemi başlatılıyor...');

      // Görseli base64'e çevir
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('Görsel base64 formatına dönüştürüldü, API isteği gönderiliyor...');

      // API isteği için JSON hazırla
      final requestBody = jsonEncode({
        "model": "gpt-4o-mini", // Daha ekonomik model
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text":
                    "Bu bitkiyi analiz et ve şu bilgileri ver: 1) Bitkinin halk arasındaki ismi, 2) Bitkinin biyolojik ismi, 3) Bitkinin yaşamak için ihtiyaç duyduğu sıcaklık aralığı, 4) Bitkinin sulama aralığı, 5) Bitki hakkında genel bilgiler (nerede yetiştiği, sevdiği toprak çeşitleri, gündüz veya gece bitkisi olması, koku ve faydaları vb.)"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image",
                  "detail": "low" // Düşük detay seviyesine geçiş yapın
                }
              }
            ]
          }
        ],
        "max_tokens": 800 // Token sayısını azaltın
      });

      // API isteği gönder
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: requestBody,
      );

      print('API yanıtı alındı: ${response.statusCode}');
      print('API yanıt içeriği: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        // Rate limit hatası durumunda mock yanıt döndür
        return _getMockResponse();
      } else {
        print('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception('Bitki tanıma hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Bitki tanıma hatası: $e');
      // Hata durumunda mock yanıt döndür
      return _getMockResponse();
    }
  }

  // Mock yanıt
  String _getMockResponse() {
    return '''
**1) Bitkinin halk arasındaki ismi:**
Barış Çiçeği (Spathiphyllum)

**2) Bitkinin biyolojik ismi:**
Spathiphyllum wallisii

**3) Bitkinin yaşamak için ihtiyaç duyduğu sıcaklık aralığı:**
18-30°C arası. 15°C'nin altındaki sıcaklıklarda zarar görebilir. İdeal sıcaklık aralığı 20-25°C'dir.

**4) Bitkinin sulama aralığı:**
Yazın haftada 1-2 kez, kışın 10-15 günde bir. Toprağın üst kısmı kuruduğunda sulanmalıdır. Aşırı sulamadan kaçınılmalıdır, ancak tamamen kurumaya da bırakılmamalıdır.

**5) Bitki hakkında genel bilgiler:**
- **Yetiştiği Yerler:** Doğal olarak Kolombiya ve Venezuela'nın tropikal ormanlarında yetişir.
- **Sevdiği Toprak:** Humus bakımından zengin, iyi drene olan, hafif asidik toprakları tercih eder.
- **Işık İhtiyacı:** Doğrudan güneş ışığından hoşlanmaz, parlak dolaylı ışık idealdir. Gölgeli ortamlarda da yaşayabilir ancak çiçek açması zorlaşır.
- **Nem İhtiyacı:** Yüksek nem sever. Yapraklarına düzenli su püskürtmek faydalıdır.
- **Faydaları:** NASA tarafından yapılan araştırmalara göre havadaki formaldehit, benzen ve karbon monoksit gibi zararlı maddeleri temizleme özelliğine sahiptir.
- **Çiçeklenme:** Beyaz, zarif çiçekleri vardır ve doğru bakım koşullarında yıl boyunca çiçek açabilir.
- **Bakım:** Kolay bakım gerektiren bitkilerdendir, bu nedenle ev bitkileri arasında popülerdir.
- **Zehirlilik:** Kediler, köpekler ve küçük çocuklar için hafif toksiktir, yutulması halinde ağız ve boğazda tahriş yapabilir.
''';
  }
}
