class User {
  final int id;
  final String correo;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String rol; // 'ADMIN' o 'CLIENTE'
  final bool isActive;
  final String? dateJoined;
  final int? clienteId; // ID del cliente asociado si es un usuario cliente

  User({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    this.telefono,
    required this.rol,
    required this.isActive,
    this.dateJoined,
    this.clienteId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Convertiendo JSON a User: $json'); // Para debug
    return User(
      id: json['id'] ?? 0,
      correo: json['correo'] ?? json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      telefono: json['telefono'],
      rol: (json['rol'] ?? json['role'] ?? 'CLIENTE').toString().toUpperCase(),
      isActive: json['is_active'] ?? json['activo'] ?? true,
      dateJoined: json['date_joined'],
      clienteId: json['cliente_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'rol': rol,
      'is_active': isActive,
      'date_joined': dateJoined,
      'cliente_id': clienteId,
    };
  }

  String get fullName => '$nombre $apellido'.trim();
  String get email => correo; // Alias para compatibilidad
  bool get isAdmin => rol.toUpperCase() == 'ADMIN';
  bool get isClient => rol.toUpperCase() == 'CLIENTE';
}