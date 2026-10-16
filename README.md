# aluga-crajubar-mobile

## API

O app consome a API Laravel do repositório `GiselleAFr/aluga-crajubar`, branch
`develop`. O endereço do GitHub é o código-fonte, não um servidor HTTP da API:
inicie o backend localmente ou informe o endereço de uma instância implantada.
Configure a URL base ao executar o Flutter:

- Android Emulator: `http://10.0.2.2:8000/api` (padrão do app).
- Dispositivo físico: `http://IP_DA_MAQUINA:8000/api`; inicie o Laravel ouvindo
	em `0.0.0.0` e use o IP da máquina na rede local.
- Linux: `http://127.0.0.1:8000/api`.

Para sobrescrever o padrão, passe `--dart-define=API_BASE_URL=<URL>` ao
`flutter run`/build. HTTP sem TLS só é permitido no Android debug; use HTTPS em
produção e no iOS.

Login, cadastro, recuperação, redefinição de senha, consulta da sessão, perfil
e histórico de hospedagens usam os endpoints `/auth` da API. Perfil e histórico
são carregados nas opções **Perfil** e **Reservas** da navegação. O cadastro
envia nome, e-mail, telefone e senha; a branch `develop` exige e normaliza o
telefone. O token Bearer é guardado no armazenamento seguro do dispositivo.

A home e a busca consomem `GET /imoveis`, com os filtros `q`, `tipo` e
`per_page` (até 100 registros). A API retorna uma página em `data`, com campos
como `titulo`, `tipo`, `finalidade`, `preco`, `unidade_preco`, `cidade` e
`bairro`; imagens e avaliações podem estar ausentes, e nesse caso o app mostra
um marcador visual padrão.

Inicie o backend Laravel na porta 8000 e execute o app com a URL da API. Em
dispositivo físico, substitua `IP_DA_MAQUINA` pelo endereço local do computador;
`localhost` no celular apontaria para o próprio celular.