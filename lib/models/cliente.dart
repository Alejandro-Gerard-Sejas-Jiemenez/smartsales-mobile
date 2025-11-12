import 'user.dart';

class Cliente {
  final int id;
  final User usuario;
  final String? ciudad;
  final String? codigoPostal;

  Cliente({
    required this.id,
    required this.usuario,
    this.ciudad,
    this.codigoPostal,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? 0,
      usuario: User.fromJson(json['usuario'] ?? {}),
      ciudad: json['ciudad'],
      codigoPostal: json['codigo_postal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario.toJson(),
      'ciudad': ciudad,
      'codigo_postal': codigoPostal,
    };
  }
}
