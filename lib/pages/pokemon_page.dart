import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({Key? key}) : super(key: key);

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  Future<List<dynamic>> getPokemons() async {
  try {
    final dio = Dio();
    final response = await dio.get("https://pokeapi.co/api/v2/pokemon/");
    final data = response.data;

    final listaDePokemons = <dynamic>[];
    final listaDePokemonsInfos = <dynamic>[];

    data["results"].forEach((pokemon) {
      listaDePokemons.add(pokemon);
    });

    await Future.wait(listaDePokemons.map((element) async {
      final response = await dio.get(element["url"]);
      final data1 = response.data;
      listaDePokemonsInfos.add(data1);
    }));

    return listaDePokemonsInfos;
  } catch (error) {
    
    print("Erro ao obter a lista de Pokémons: $error");
    return []; 
  }
}


  void showPokemonDetails(dynamic pokemon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue[100], // Definindo a cor de fundo
          title: Text(pokemon["name"]),
          content: Container(
            color: const Color.fromARGB(
                255, 196, 226, 240), // Definindo a cor de fundo
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                    pokemon['sprites']['other']['official-artwork']
                        ['front_default'],
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 5),
                  Align(child: Text("ID: ${pokemon["id"]}")),
                  const SizedBox(height: 5),
                  Text("Altura: ${pokemon["height"]}"),
                  const SizedBox(height: 5),
                  Text("Peso: ${pokemon["weight"]}"),
                  const SizedBox(height: 5),
                  const Text("Habilidades: "),
                  const SizedBox(height: 5),
                  for (dynamic habilidade in pokemon["abilities"])
                    Text(habilidade["ability"]["name"]),
                  const SizedBox(height: 5),
                  const Text("Tipo(s): "),
                  const SizedBox(height: 5),
                  for (dynamic type in pokemon['types'])
                    Text(type['type']['name'])
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: getPokemons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Ocorreu um erro no carregamento"),
            );
          } else {
            return SingleChildScrollView(
              child: Column(children: [
                Column(
                  children: [
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: Image.asset(
                        "lib/assets/pokedex.png",
                      ),
                    ),
                    const Text("POKEDEX", style: TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final pokemon = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            showPokemonDetails(pokemon);
                          },
                          leading: Image.network(
                              pokemon["sprites"]["front_default"]),
                          title: Text(pokemon["name"]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            );
          }
        },
      ),
    );
  }
}
