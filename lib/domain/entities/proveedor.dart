class Proveedor {
  const Proveedor({
    required this.id,
    required this.nombre,
    this.rubro,
    this.contacto,
    this.telefono,
    this.whatsapp,
    this.email,
    this.direccion,
    this.localidad,
    this.notas,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String? rubro;
  final String? contacto;
  final String? telefono;
  final String? whatsapp;
  final String? email;
  final String? direccion;
  final String? localidad;
  final String? notas;
  final bool activo;

  Proveedor copyWith({
    String? nombre,
    String? rubro,
    String? contacto,
    String? telefono,
    String? whatsapp,
    String? email,
    String? direccion,
    String? localidad,
    String? notas,
    bool? activo,
  }) {
    return Proveedor(
      id: id,
      nombre: nombre ?? this.nombre,
      rubro: rubro ?? this.rubro,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      localidad: localidad ?? this.localidad,
      notas: notas ?? this.notas,
      activo: activo ?? this.activo,
    );
  }
}
