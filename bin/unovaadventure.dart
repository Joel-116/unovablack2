import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon.dart';

void main() async {
  await explorarUnova();
  await pokemonLocal(347);
  List<Pokemon> timeUnova = await meuPokemon();

  print("\n--- 🛰️  SINCRONIZANDO DADOS TÉCNICOS DA EQUIPE ---");

  for (var pokemon in timeUnova) {
    pokemon.natureDetalhes = await buscarEfeitoNature(pokemon.nature);
  }

  print("\n--- ⚔️  RELATÓRIO POKÉDEX ATUALIZADO ---");
  for (var pokemon in timeUnova) {
    print(pokemon); 
  }
  
  print("\n--- ✅ Relatório concluído! ---");
}

Future<void> explorarUnova() async {
  final url = Uri.parse('https://pokeapi.co/api/v2/region/5/'); // Unova é a região 5 na PokeAPI, aqui vamos aceessá-la e ao mesmo tempo transformar em URI

  try { // O try catch serve para evitar que o programa quebre caso haja um erro na requisição
    print("--- INICIANDO JORNADA EM UNOVA (BLACK 2) ---");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> pokeApi = json.decode(response.body);

      // Aqui pegamos a lista de todos os locais (Cidades, Rotas, Cavernas)
      List<dynamic> locais = pokeApi['locations'];

      print("Região detectada: ${pokeApi['name'].toUpperCase()}");
      print("Locais disponíveis para exploração: ${locais.length}\n");

      // Listando todos os locais
      int i = 0;
      
      for (var local in locais) {
        String url = local['url']; // A URL para acessar detalhes do local
        
        // Quebramos a URL pelas barras "/", o número gerado vai ser o ID de cada local
        // Lembre-se isso aqui corta a URL pra pegar o ID. Se mexer em alguma coisa vai quebrar.
        List<String> partes = url.split('/');
        String idEncontrado = partes[partes.length - 2]; 
        // Depois de dividir, o ID está na penúltima posição sendo o número 6, pois a última é vazia após a barra final. 0 a 7 temos 8 partes, então partes.length (8) -  2 = 6, assim acessamos o ID.
        i++; // Para incrementar o contador de locais, se não vai ficar sempre no 0.
        print("Ponto de interesse #$i: ${local['name']} | ID para usar: $idEncontrado");
      }
    } else {
      print("Erro ao acessar Unova: ${response.statusCode}");
    }
  } catch (e) {
    print("Falha na conexão com o sistema GPS: $e");
  }
}

Future<void> pokemonLocal(int idLocal) async {
  // Você acessa a localização do local escolhido, um ID deve ser escolhido no main.
  final urlLocalizacao = Uri.parse('https://pokeapi.co/api/v2/location/$idLocal/');
  final responseLocal = await http.get(urlLocalizacao);

  if (responseLocal.statusCode == 200) {
    Map<String, dynamic> dadosLocal = json.decode(responseLocal.body); // Pegamos a URL da primeira ÁREA desta rota

    String nomeDoLocal = dadosLocal['name'].toString().toUpperCase().replaceAll('-', ' '); //Pega o nome do local que estamos

    List<dynamic> areas = dadosLocal['areas']; // Pega as áreas dentro do local
    
    if (areas.isEmpty) {
      print("\n--- 🏙️  $nomeDoLocal ---");
      print("Status: Zona Segura. Não há Pokémons selvagens aqui.");
      return; // Sai da função e não tenta ler o que não existe
    }
    
    String urlArea = dadosLocal['areas'][0]['url']; // A PokeAPI separa assim: Local -> Área -> Encontros
    
    final responseArea = await http.get(Uri.parse(urlArea));
    Map<String, dynamic> dadosArea = json.decode(responseArea.body); // Pegamos os encontros de pokémons nesta área

    List<dynamic> encontros = dadosArea['pokemon_encounters']; // Lista de pokémons que aparecem na área
    
    print("\n--- 🌿 Pokémons que aparecem na $nomeDoLocal ---");

    if (encontros.isEmpty) {
      print("Nenhum Pokémon encontrado nesta área específica.");
    } else {
      for (var registro in encontros) {
        var pokemon = registro['pokemon'];
        print("Avistado: ${pokemon['name'].toUpperCase()}");
      }
    } 
  }
}

Future<StatusNature?> buscarEfeitoNature(String nomeNature) async {
  final url = Uri.parse('https://pokeapi.co/api/v2/nature/${nomeNature.toLowerCase()}');
  
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var dados = json.decode(response.body);

      return StatusNature(
        nome: dados['name'],
        aumenta: dados['increased_stat']?['name'] ?? "Nenhum",
        diminui: dados['decreased_stat']?['name'] ?? "Nenhum",
      );
    }
  } catch (e) {
    print("Erro ao buscar nature: $e");
  }
  return null;
}

dynamic meuPokemon() {
  Pokemon marie = Pokemon(especie: "Venipede", apelido: "Marie", genero: "Fêmea", nature: "Adamant");
  Pokemon mary = Pokemon(especie: "Riolu", apelido: "Mary", genero: "Fêmea", nature: "Adamant");
  Pokemon dewott = Pokemon(especie: "Dewott", genero: "Macho", nature: "Adamant");
  Pokemon sewaddle = Pokemon(especie: "Sewaddle", genero: "Macho", nature: "Adamant");
  Pokemon flaaffy = Pokemon(especie: "Flaaffy", genero: "Fêmea", nature: "Modest");

  return [marie, mary, dewott, sewaddle, flaaffy];
}
