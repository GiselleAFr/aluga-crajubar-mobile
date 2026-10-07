# aluga-crajubar-mobile

## API

O app consome a API Laravel do repositório `GiselleAFr/aluga-crajubar`, branch
`login-back`. Configure a URL base ao executar o Flutter:

- Android Emulator: `http://10.0.2.2:8000/api` (padrão do app).
- Dispositivo físico: `http://IP_DA_MAQUINA:8000/api`; inicie o Laravel ouvindo
	em `0.0.0.0` e use o IP da máquina na rede local.
- Linux: `http://127.0.0.1:8000/api`.

Para sobrescrever o padrão, passe `--dart-define=API_BASE_URL=<URL>` ao
`flutter run`/build. HTTP sem TLS só é permitido no Android debug; use HTTPS em
produção e no iOS.

Login, cadastro, recuperação e redefinição de senha usam os endpoints `/auth`
da API. O cadastro envia nome, e-mail, telefone e senha; a API normaliza o
telefone para o formato internacional. O token Bearer é guardado no
armazenamento seguro do dispositivo.