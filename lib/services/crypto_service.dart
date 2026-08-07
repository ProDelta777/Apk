import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class CryptoService {
  final IV _iv;
  final Encrypter _encrypter;

  CryptoService._(this._iv, this._encrypter);

  factory CryptoService.init(String secret) {
    // In a production app with true E2EE, this secret would be derived via a key exchange protocol (e.g. ECDH) per chat session.
    // For this prototype, we generate a key from a shared secret to simulate the encryption step before network transmission.
    final hashedKey = sha256.convert(utf8.encode(secret)).bytes;
    final key = Key(Uint8List.fromList(hashedKey));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    return CryptoService._(iv, encrypter);
  }

  String encryptMessage(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptMessage(String encryptedText) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return "Error: Could not decrypt message";
    }
  }
}
