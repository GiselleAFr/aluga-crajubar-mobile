/// E-mail do suporte exibido ao final da tela de Ajuda.
const String supportEmail = 'alugacrajubar@gmail.com';

class FaqItem {
  const FaqItem({
    required this.id,
    required this.categoria,
    required this.pergunta,
    required this.resposta,
  });

  final String id;
  final String categoria;
  final String pergunta;
  final String resposta;
}

/// Ordem em que as categorias aparecem na tela.
const List<String> faqCategorias = [
  'Primeiros passos',
  'Valores e pagamento',
  'Minhas reservas',
  'Falar com o locador',
  'Conta e anúncios',
];

const List<FaqItem> faqItens = [
  // ---------------------------------------------------------- Primeiros passos
  FaqItem(
    id: 'buscar',
    categoria: 'Primeiros passos',
    pergunta: 'Como encontro um imóvel?',
    resposta:
        'Use o campo de busca no topo da tela inicial ou a aba Buscar. '
        'Você pode digitar o nome, o bairro, a cidade ou o tipo do imóvel e '
        'filtrar por categoria: casas, apartamentos, quartos e pousadas, '
        'comerciais e terrenos.',
  ),
  FaqItem(
    id: 'reservar',
    categoria: 'Primeiros passos',
    pergunta: 'Como faço uma reserva?',
    resposta:
        '1. Abra o imóvel que você gostou.\n'
        '2. Toque em “Solicitar reserva”.\n'
        '3. Escolha as datas e a quantidade de hóspedes.\n'
        '4. Confira o valor estimado e envie a solicitação.\n\n'
        'A solicitação chega ao locador, que vai analisá-la.',
  ),
  FaqItem(
    id: 'garantida',
    categoria: 'Primeiros passos',
    pergunta: 'A reserva já está garantida depois que eu envio?',
    resposta:
        'Ainda não. O que você envia é uma solicitação, e ela só vale '
        'depois que o locador aprovar. Enquanto isso, ela fica como '
        '“Pendente” na aba Reservas. Quando o locador responder, o status '
        'muda para “Confirmada” ou “Recusada”.',
  ),

  // ------------------------------------------------------ Valores e pagamento
  FaqItem(
    id: 'valor',
    categoria: 'Valores e pagamento',
    pergunta: 'Como o valor da reserva é calculado?',
    resposta:
        'Nos imóveis de diária, o total é o preço da diária multiplicado '
        'pelo número de diárias, do check-in ao check-out.\n\n'
        'Nos imóveis mensais, é o preço do mês multiplicado pela quantidade '
        'de meses completos, e a saída cai sempre no mesmo dia do mês da '
        'entrada.\n\n'
        'O valor mostrado é uma estimativa feita com o preço do anúncio.',
  ),
  FaqItem(
    id: 'pagamento',
    categoria: 'Valores e pagamento',
    pergunta: 'Como funciona o pagamento?',
    resposta:
        'O AlugaCrajubar ainda não processa pagamentos pelo app. Combine a '
        'forma de pagamento diretamente com o locador.',
  ),

  // ----------------------------------------------------------- Minhas reservas
  FaqItem(
    id: 'prazo',
    categoria: 'Minhas reservas',
    pergunta: 'Quanto tempo o locador demora para responder?',
    resposta:
        'Não há um prazo fixo: cada locador responde no seu tempo. Você '
        'acompanha o status na aba Reservas (arraste a tela para baixo para '
        'atualizar). Se quiser agilizar, chame o locador pelo WhatsApp na '
        'página do imóvel.',
  ),
  FaqItem(
    id: 'cancelar',
    categoria: 'Minhas reservas',
    pergunta: 'Posso cancelar uma reserva?',
    resposta:
        'Pode, até o dia anterior à data de entrada. Na aba Reservas, toque '
        'na reserva e escolha “Cancelar reserva” (ou “Cancelar '
        'solicitação”, se ainda estiver pendente).\n\n'
        'Quando a data de entrada chega, o cancelamento pelo app não é mais '
        'possível.',
  ),
  FaqItem(
    id: 'recusada',
    categoria: 'Minhas reservas',
    pergunta: 'Minha solicitação foi recusada. E agora?',
    resposta:
        'A decisão é do locador, e o app não mostra o motivo. Você pode '
        'escolher outras datas ou outro imóvel: use a aba Buscar para ver '
        'mais opções.',
  ),

  // ------------------------------------------------------- Falar com o locador
  FaqItem(
    id: 'whatsapp',
    categoria: 'Falar com o locador',
    pergunta: 'Como falo com o locador?',
    resposta:
        'Na página do imóvel, toque em “Conversar pelo WhatsApp”: a conversa '
        'abre com uma mensagem pronta. Ali você também vê o telefone do '
        'locador e pode copiá-lo para ligar ou salvar nos seus contatos.',
  ),
  FaqItem(
    id: 'whatsapp-desativado',
    categoria: 'Falar com o locador',
    pergunta: 'O botão do WhatsApp está desativado. Por quê?',
    resposta:
        'Isso acontece quando o locador ainda não cadastrou um telefone. '
        'Nesse caso, use as informações do anúncio ou escreva para a nossa '
        'equipe por e-mail.',
  ),

  // --------------------------------------------------------- Conta e anúncios
  FaqItem(
    id: 'senha',
    categoria: 'Conta e anúncios',
    pergunta: 'Esqueci minha senha. O que faço?',
    resposta:
        'Na tela de login, use a opção de recuperação de senha, informe o '
        'seu e-mail e siga as instruções que enviaremos para você.',
  ),
  FaqItem(
    id: 'anunciar',
    categoria: 'Conta e anúncios',
    pergunta: 'Quero anunciar meu imóvel. Como faço?',
    resposta:
        'Você pode pedir para se tornar locador pelo banner “Anuncie seu '
        'imóvel”, na tela inicial, ou em Perfil > Tornar-se um Locador. '
        'Nossa equipe analisa o pedido e avisa você sobre a decisão.',
  ),
];
