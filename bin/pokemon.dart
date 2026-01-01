class Pokemon {
  String especie;
  String? apelido;
  String genero;
  String nature;
  StatusNature? natureDetalhes; // O compartimento para os dados da API

  Pokemon({
    required this.especie,
    this.apelido,
    required this.genero,
    required this.nature,
  });

  @override
  String toString() {
    String nomeExibicao = apelido ?? especie;
    String info =
        "$nomeExibicao ($especie) | $genero | Nature: ${nature.toUpperCase()}";
    
    if (natureDetalhes != null) {
      info +=
          " (📈 ${natureDetalhes!.aumenta} / 📉 ${natureDetalhes!.diminui})";
    }

    return info;
  }
}

class StatusNature {
  final String nome;
  final String aumenta;
  final String diminui;

  StatusNature({
    required this.nome,
    required this.aumenta,
    required this.diminui,
  });
}
