class Station {
  final int id;
  final String nome;
  final String categoria;
  final String desc;
  final String regiao;
  final String imagem;
  final String urlStream;

  Station({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.desc,
    required this.regiao,
    required this.imagem,
    required this.urlStream,
  });

  factory Station.fromMap(Map<String, dynamic> map) {
    return Station(
      id: map['id'],
      nome: map['nome'],
      categoria: map['categoria'],
      desc: map['desc'],
      regiao: map['regiao'],
      imagem: map['imagem'],
      urlStream: map['urlStream'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'desc': desc,
      'regiao': regiao,
      'imagem': imagem,
      'urlStream': urlStream,
    };
  }
}
