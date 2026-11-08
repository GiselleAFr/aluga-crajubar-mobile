import 'package:flutter/material.dart';

import '../favorites/favorites_store.dart';
import '../login/login/login.dart';
import '../responsive_content.dart';
import '../services/auth_service.dart';
import 'components/code_boxes.dart';
import 'components/security_buttons.dart';
import 'components/security_colors.dart';
import 'components/security_header.dart';
import 'components/security_password_field.dart';

/// Tela "Segurança e Login": alteração de senha com confirmação por código
/// de 6 dígitos enviado por e-mail.
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key, this.authService});

  final AuthService? authService;

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  static const _mensagemSucesso =
      'Senha alterada com sucesso. Faça login novamente.';
  static const _mensagemSessaoExpirada = 'Sua sessão expirou. Entre novamente.';
  static const _mensagemMuitasTentativas =
      'Muitas tentativas. Aguarde um minuto e tente novamente.';
  static const _mensagemErroServidor =
      'O servidor encontrou um problema. Tente novamente em instantes.';

  late final AuthService _authService;
  late final bool _ownsAuthService;

  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _codigoKey = GlobalKey<CodeBoxesState>();

  String? _erroSenhaAtual;
  String? _erroNovaSenha;
  String? _erroConfirmarSenha;

  bool _alterando = false;
  bool _verificando = false;
  bool _reenviando = false;

  /// Vira verdadeiro quando o servidor aceita a solicitação (202) nesta
  /// sessão da tela; só então "Enviar Código" fica habilitado.
  bool _codigoSolicitado = false;

  bool get _ocupado => _alterando || _verificando || _reenviando;

  @override
  void initState() {
    super.initState();
    _ownsAuthService = widget.authService == null;
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    if (_ownsAuthService) {
      _authService.close();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------
  void _aviso(String mensagem) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  void _limparSenhas() {
    _senhaAtualController.clear();
    _novaSenhaController.clear();
    _confirmarSenhaController.clear();
  }

  /// Limpa as caixas e devolve o foco à primeira (depois do próximo frame, para
  /// que as caixas já estejam habilitadas de novo).
  void _reiniciarCodigo() {
    _codigoKey.currentState?.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codigoKey.currentState?.focusFirst();
    });
  }

  String _mensagemDoErro(AuthException erro) {
    final status = erro.statusCode;
    if (status == 429) {
      return _mensagemMuitasTentativas;
    }
    if (status != null && status >= 500) {
      return _mensagemErroServidor;
    }
    return erro.message;
  }

  /// Encerra a sessão local e volta ao login, sem pilha de navegação anterior.
  Future<void> _irParaLogin(String mensagem) async {
    _limparSenhas();
    await _authService.clearSession();
    FavoritesStore.instance.clear();

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(initialMessage: mensagem),
      ),
      (route) => false,
    );
  }

  // ---------------------------------------------------------------------------
  // Alterar senha (POST /auth/change-password)
  // ---------------------------------------------------------------------------
  bool _validar() {
    final atual = _senhaAtualController.text;
    final nova = _novaSenhaController.text;
    final confirmacao = _confirmarSenhaController.text;

    String? erroAtual;
    String? erroNova;
    String? erroConfirmacao;

    if (atual.isEmpty) {
      erroAtual = 'Informe sua senha atual.';
    }

    if (nova.isEmpty) {
      erroNova = 'Informe sua nova senha.';
    } else if (nova.length < 8) {
      erroNova = 'A nova senha deve ter pelo menos 8 caracteres.';
    } else if (nova == atual) {
      erroNova = 'A nova senha deve ser diferente da senha atual.';
    }

    if (confirmacao.isEmpty) {
      erroConfirmacao = 'Confirme a nova senha.';
    } else if (confirmacao != nova) {
      erroConfirmacao = 'A confirmação não confere com a nova senha.';
    }

    setState(() {
      _erroSenhaAtual = erroAtual;
      _erroNovaSenha = erroNova;
      _erroConfirmarSenha = erroConfirmacao;
    });

    return erroAtual == null && erroNova == null && erroConfirmacao == null;
  }

  Future<void> _alterarSenha() async {
    if (_ocupado) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_validar()) {
      return;
    }

    setState(() => _alterando = true);
    try {
      final mensagem = await _authService.requestPasswordChange(
        currentPassword: _senhaAtualController.text,
        password: _novaSenhaController.text,
        passwordConfirmation: _confirmarSenhaController.text,
      );
      if (!mounted) {
        return;
      }
      _limparSenhas();
      setState(() {
        _codigoSolicitado = true;
        _erroSenhaAtual = null;
        _erroNovaSenha = null;
        _erroConfirmarSenha = null;
      });
      _reiniciarCodigo();
      _aviso(mensagem);
    } on AuthException catch (erro) {
      if (!mounted) {
        return;
      }
      if (erro.statusCode == 401) {
        await _irParaLogin(_mensagemSessaoExpirada);
        return;
      }
      final erroAtual = erro.fieldErrors['current_password'];
      final erroNova = erro.fieldErrors['password'];
      if (erro.statusCode == 422 && (erroAtual != null || erroNova != null)) {
        setState(() {
          _erroSenhaAtual = erroAtual;
          _erroNovaSenha = erroNova;
        });
      } else {
        _aviso(_mensagemDoErro(erro));
      }
    } catch (_) {
      _aviso('Não foi possível solicitar a alteração. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _alterando = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Confirmar o código (POST /auth/change-password/verify-code)
  // ---------------------------------------------------------------------------
  Future<void> _verificarCodigo(String codigo) async {
    if (_ocupado) {
      return;
    }

    setState(() => _verificando = true);
    try {
      await _authService.verifyPasswordChangeCode(code: codigo);
      if (!mounted) {
        return;
      }
      await _irParaLogin(_mensagemSucesso);
      return;
    } on AuthException catch (erro) {
      if (!mounted) {
        return;
      }
      if (erro.statusCode == 401) {
        await _irParaLogin(_mensagemSessaoExpirada);
        return;
      }
      _aviso(_mensagemDoErro(erro));
      _reiniciarCodigo();
    } catch (_) {
      _aviso('Não foi possível confirmar o código. Tente novamente.');
      _reiniciarCodigo();
    } finally {
      if (mounted) {
        setState(() => _verificando = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Reenviar o código (POST /auth/change-password/resend-code)
  // ---------------------------------------------------------------------------
  Future<void> _reenviarCodigo() async {
    if (_ocupado || !_codigoSolicitado) {
      return;
    }

    setState(() => _reenviando = true);
    try {
      final mensagem = await _authService.resendPasswordChangeCode();
      if (!mounted) {
        return;
      }
      _aviso(mensagem);
      _reiniciarCodigo();
    } on AuthException catch (erro) {
      if (!mounted) {
        return;
      }
      if (erro.statusCode == 401) {
        await _irParaLogin(_mensagemSessaoExpirada);
        return;
      }
      if (erro.statusCode == 422) {
        // Não há alteração pendente: é preciso solicitar de novo.
        setState(() => _codigoSolicitado = false);
      }
      _aviso(_mensagemDoErro(erro));
    } catch (_) {
      _aviso('Não foi possível reenviar o código. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => _reenviando = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SecurityHeader(onBack: () => Navigator.of(context).maybePop()),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ResponsiveContent(
            maxWidth: 640,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alterar Senha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SecurityColors.vinho,
                  ),
                ),
                const SizedBox(height: 16),
                SecurityPasswordField(
                  key: const Key('senha-atual'),
                  label: 'Senha Atual',
                  controller: _senhaAtualController,
                  errorText: _erroSenhaAtual,
                  enabled: !_alterando,
                  onChanged: (_) {
                    if (_erroSenhaAtual != null) {
                      setState(() => _erroSenhaAtual = null);
                    }
                  },
                ),
                const SizedBox(height: 14),
                SecurityPasswordField(
                  key: const Key('nova-senha'),
                  label: 'Nova Senha',
                  controller: _novaSenhaController,
                  errorText: _erroNovaSenha,
                  enabled: !_alterando,
                  onChanged: (_) {
                    if (_erroNovaSenha != null) {
                      setState(() => _erroNovaSenha = null);
                    }
                  },
                ),
                const SizedBox(height: 14),
                SecurityPasswordField(
                  key: const Key('confirmar-senha'),
                  label: 'Confirmar Nova Senha',
                  controller: _confirmarSenhaController,
                  errorText: _erroConfirmarSenha,
                  enabled: !_alterando,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (_erroConfirmarSenha != null) {
                      setState(() => _erroConfirmarSenha = null);
                    }
                  },
                  onSubmitted: (_) => _alterarSenha(),
                ),
                const SizedBox(height: 22),
                SecurityFilledButton(
                  key: const Key('btn-alterar'),
                  label: 'Alterar Senha',
                  isLoading: _alterando,
                  onPressed: _ocupado ? null : _alterarSenha,
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: SecurityColors.borda),
                const SizedBox(height: 24),
                const Text(
                  'Verificação por E-mail',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SecurityColors.vinho,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Para sua segurança, enviaremos um código de verificação de '
                  '6 dígitos para o seu e-mail cadastrado antes de confirmar '
                  'transações importantes.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                CodeBoxes(
                  key: _codigoKey,
                  enabled: !_verificando,
                  onCompleted: _verificarCodigo,
                ),
                const SizedBox(height: 26),
                SecurityOutlinedButton(
                  key: const Key('btn-enviar-codigo'),
                  label: 'Enviar Código',
                  isLoading: _reenviando,
                  onPressed: (_codigoSolicitado && !_ocupado)
                      ? _reenviarCodigo
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
