class Station {
  final int id;
  final String nome;
  final String desc;
  final String regiao;
  final String categoria;
  final String imagem;
  final String urlStream;

  Station({
    required this.id,
    required this.nome,
    required this.desc,
    required this.regiao,
    required this.categoria,
    required this.imagem,
    required this.urlStream,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      nome: json['nome'],
      desc: json['desc'] ?? 'Estação de rádio',
      regiao: json['regiao'] ?? 'Moçambique',
      categoria: json['categoria'] ?? 'Variedades',
      imagem:
          json['imagem'] ?? 'https://placehold.co/400/8e4b4c/white?text=RADIO',
      urlStream: json['urlStream'] ?? '#',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'desc': desc,
      'regiao': regiao,
      'categoria': categoria,
      'imagem': imagem,
      'urlStream': urlStream,
    };
  }
}
