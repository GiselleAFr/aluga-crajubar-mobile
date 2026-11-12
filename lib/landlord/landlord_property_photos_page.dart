import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';

import 'landlord_property_details_page.dart';
import 'models/landlord_property_address.dart';
import 'models/landlord_property_draft.dart';

class LandlordPropertyPhotosPage extends StatefulWidget {
  const LandlordPropertyPhotosPage({
    super.key,
    required this.address,
    this.initialProperty,
    this.onPropertyCreated,
    this.onPickFiles,
  });

  final LandlordPropertyAddress address;
  final LandlordPropertyDraft? initialProperty;
  final ValueChanged<LandlordPropertyDraft>? onPropertyCreated;
  final Future<List<Uint8List>?> Function(int remaining)? onPickFiles;

  @override
  State<LandlordPropertyPhotosPage> createState() =>
      _LandlordPropertyPhotosPageState();
}

class _LandlordPropertyPhotosPageState
    extends State<LandlordPropertyPhotosPage> {
  static const _wine = Color(0xFFA83232);
  static const _almond = Color(0xFFE8BDBD);
  static const _soft = Color(0xFFFDECEC);
  static const _maxPhotos = 10;

  final List<Uint8List> _photos = [];
  int? _mainPhotoIndex;
  bool _isPicking = false;

  bool get _isEditing => widget.initialProperty != null;

  @override
  void initState() {
    super.initState();
    final property = widget.initialProperty;
    if (property != null) {
      _photos.addAll(property.photos);
      _mainPhotoIndex = property.mainPhotoIndex;
    }
  }

  Widget _dashedBorder({required Widget child, required double radius}) =>
      CustomPaint(
        foregroundPainter: _DashedBorderPainter(color: _almond, radius: radius),
        child: child,
      );

  Future<List<Uint8List>?> _pickImages(int remaining) async {
    final selected = await openFiles(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Imagens', extensions: ['jpg', 'jpeg', 'png']),
      ],
    );
    return Future.wait(selected.map((image) => image.readAsBytes()));
  }

  Future<void> _addImages() async {
    if (_isPicking || _photos.length >= _maxPhotos) return;

    setState(() => _isPicking = true);
    try {
      final remaining = _maxPhotos - _photos.length;
      final picked =
          await (widget.onPickFiles?.call(remaining) ?? _pickImages(remaining));
      if (!mounted || picked == null || picked.isEmpty) return;

      final additions = picked.take(remaining).toList();
      setState(() {
        _mainPhotoIndex ??= 0;
        _photos.addAll(additions);
      });

      if (picked.length > remaining) {
        _showMessage('É possível adicionar no máximo $_maxPhotos fotos.');
      }
    } on PlatformException catch (error) {
      debugPrint('Não foi possível selecionar as fotos: ${error.message}');
      if (mounted) {
        _showMessage('Não foi possível acessar as fotos do dispositivo.');
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      if (_photos.isEmpty) {
        _mainPhotoIndex = null;
      } else if (_mainPhotoIndex == index) {
        _mainPhotoIndex = 0;
      } else if (_mainPhotoIndex != null && _mainPhotoIndex! > index) {
        _mainPhotoIndex = _mainPhotoIndex! - 1;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _continue() {
    if (_photos.isEmpty) {
      _showMessage('Adicione ao menos uma foto para continuar.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LandlordPropertyDetailsPage(
          address: widget.address,
          photos: List.unmodifiable(_photos),
          mainPhotoIndex: _mainPhotoIndex ?? 0,
          initialProperty: widget.initialProperty,
          onPropertyCreated: widget.onPropertyCreated,
        ),
      ),
    );
  }

  Widget _buildUploadTarget({required bool compact}) {
    final isFull = _photos.length >= _maxPhotos;
    return Semantics(
      button: true,
      label: 'Adicionar imagens',
      child: InkWell(
        onTap: isFull || _isPicking ? null : _addImages,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        child: _dashedBorder(
          radius: compact ? 16 : 20,
          child: Container(
            height: compact ? 138 : 104,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(compact ? 16 : 20),
            ),
            child: compact
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: _soft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: _wine, size: 20),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Adicionar',
                        style: TextStyle(
                          color: _wine,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: _soft,
                          shape: BoxShape.circle,
                        ),
                        child: _isPicking
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.photo_camera_outlined,
                                color: _wine,
                              ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Adicionar imagens',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'JPG ou PNG • até 10 fotos',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index, double width) {
    final isMain = index == _mainPhotoIndex;

    return SizedBox(
      key: ValueKey('property-photo-$index'),
      width: width,
      height: 138,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_photos[index], fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.92),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => _removePhoto(index),
                  tooltip: 'Remover foto',
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, color: _wine, size: 18),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: isMain
                  ? Container(
                      key: ValueKey('main-photo-$index'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _soft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '★  Foto principal',
                        style: TextStyle(
                          color: _wine,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () => setState(() => _mainPhotoIndex = index),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.92),
                        foregroundColor: _wine,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Definir como principal',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery() => LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - 10) / 2;
      final children = <Widget>[
        for (var index = 0; index < _photos.length; index++)
          _buildPhotoCard(index, itemWidth),
        if (_photos.length < _maxPhotos)
          SizedBox(width: itemWidth, child: _buildUploadTarget(compact: true)),
      ];

      return Wrap(spacing: 10, runSpacing: 16, children: children);
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FAFB),
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: _wine,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14A83232),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Voltar',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    fixedSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing ? 'Edição de imóvel' : 'Etapa 4 de 5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing ? 'Editar fotos do imóvel' : 'Fotos do imóvel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isEditing
                      ? 'Adicione, remova ou escolha a foto principal do imóvel.'
                      : 'Mostre os melhores detalhes e ajude seu anúncio a se destacar.',
                  style: TextStyle(
                    color: Color(0xFFF7DADA),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ADICIONE SUAS FOTOS',
                    style: TextStyle(
                      color: _wine,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_photos.length} de $_maxPhotos',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildUploadTarget(compact: false),
                  if (_photos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildGallery(),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _soft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Text(
                          'Use fotos claras e horizontais. A primeira imagem será a capa do anúncio.',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        height: 96,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _almond)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _continue,
            style: FilledButton.styleFrom(
              backgroundColor: _wine,
              shape: const StadiumBorder(),
              elevation: 4,
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 5).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 4;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
