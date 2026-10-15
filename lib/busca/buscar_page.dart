import 'package:flutter/material.dart';

import 'components/buscar_header.dart';
import 'components/campo_busca.dart';
import 'components/categoria_imoveis.dart';
import 'components/secao_imoveis.dart';
import 'components/buscar_bottom_navigation.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({super.key});

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController buscaController = TextEditingController();

  int categoriaSelecionada = 0;
  int indiceSelecionado = 1;

  final List<String> categorias = [
    'Casas',
    'Apartamentos',
    'Chalés',
    'Fazendas',
  ];

  final List<Map<String, dynamic>> imoveis = [
    {
      'nome': 'Pousada Padre Cícero',
      'local': 'Juazeiro do Norte',
      'preco': 350.0,
      'avaliacao': 4.9,
      'imagem':
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=700',
      'categoria': 'Casas',
    },
    {
      'nome': 'Quarto Luxuoso',
      'local': 'Juazeiro do Norte',
      'preco': 180.0,
      'avaliacao': 4.8,
      'imagem':
          'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=700',
      'categoria': 'Apartamentos',
    },
    {
      'nome': 'Chalé da Serra',
      'local': 'Crato',
      'preco': 250.0,
      'avaliacao': 4.9,
      'imagem':
          'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?w=700',
      'categoria': 'Chalés',
    },
    {
      'nome': 'Casa de Campo',
      'local': 'Barbalha',
      'preco': 420.0,
      'avaliacao': 4.7,
      'imagem':
          'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=700',
      'categoria': 'Casas',
    },
  ];

  List<Map<String, dynamic>> get imoveisFiltrados {
    final pesquisa = buscaController.text.toLowerCase().trim();

    return imoveis.where((imovel) {
      final correspondeCategoria =
          imovel['categoria'] == categorias[categoriaSelecionada];

      final correspondePesquisa =
          imovel['nome'].toString().toLowerCase().contains(pesquisa) ||
          imovel['local'].toString().toLowerCase().contains(pesquisa);

      return correspondeCategoria && correspondePesquisa;
    }).toList();
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  void selecionarCategoria(int indice) {
    setState(() {
      categoriaSelecionada = indice;
    });
  }

  void selecionarNavegacao(int indice) {
    if (indice == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    if (indice != indiceSelecionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta seção ainda não está disponível.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final encontrados = imoveisFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BuscarHeader(),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: const Text(
                      'Buscar Imóveis',
                      style: TextStyle(
                        color: Color(0xFFA83232),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CampoBusca(
                      controller: buscaController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CategoriaImoveis(
                      categorias: categorias,
                      selecionada: categoriaSelecionada,
                      onSelecionar: selecionarCategoria,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SecaoImoveis(
                    titulo: 'DESTAQUES',
                    subtitulo: 'As melhores opções de aluguel',
                    imoveis: encontrados,
                    onVerTodos: () {},
                    onReservar: (imovel) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Imóvel selecionado: ${imovel['nome']}',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  SecaoImoveis(
                    titulo: 'PERTO DE VOCÊ',
                    subtitulo: 'As melhores opções da região',
                    imoveis: encontrados.reversed.toList(),
                    onVerTodos: () {},
                    onReservar: (imovel) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Imóvel selecionado: ${imovel['nome']}',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            BuscarBottomNavigation(
              indiceSelecionado: indiceSelecionado,
              onSelecionar: selecionarNavegacao,
            ),
          ],
        ),
      ),
    );
  }
}
