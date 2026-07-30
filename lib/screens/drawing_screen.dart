import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../models/my_drawing.dart';
import '../providers/drawing_provider.dart';

enum DrawingTool { pen, line, rect, oval, eyedropper }
enum BrushType { pencil, marker, spray, calligraphy, oil, watercolor, crayon }

const _drawingTips = [
  'ابدئي برسم الأشكال الأساسية قبل التفاصيل', 'استخدمي خطوطاً خفيفة للرسم الأولي ثم قوّميها لاحقاً',
  'قارني النسب بين الأجزاء المختلفة للرسمة', 'لاحظي المناطق المضيئة والمظلمة أثناء الرسم',
  'جربي الرسم من الزوايا المختلفة لنفس الموضوع', 'استخدمي شبكة المساعدة لتحسين التناسق',
  'ارسمي بخفة أولاً ثم زيدي التفاصيل تدريجياً', 'جربي أداة التناظر للرسم المتناسق',
  'الرسم ليس كمالاً، بل تعبير عن الإحساس', 'شاهدي أعمال فنانين آخرين للإلهام',
  'جربي أدوات رسم مختلفة (فحم، ألوان مائية، رصاص)', 'ارسمي شيئاً واحداً كل يوم لتتحسني',
];

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});
  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final TransformationController _transformCtrl = TransformationController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleCtrl = TextEditingController();

  List<_DrawingStroke> _strokes = [];
  List<_DrawingShape> _shapes = [];
  _DrawingStroke? _currentStroke;
  _DrawingShape? _currentShape;

  DrawingTool _currentTool = DrawingTool.pen;
  BrushType _brushType = BrushType.pencil;
  Color _currentColor = Colors.black;
  Color _canvasBg = Colors.white;
  double _strokeWidth = 3.0;
  double _opacity = 1.0;
  bool _isEraser = false;
  bool _showGrid = false;
  bool _symmetryMode = false;
  Offset? _shapeStart;
  Offset? _cursorPos;

  File? _refImage;
  ui.Image? _loadedRefImage;
  double _refOpacity = 0.3;

  String _currentTip = _drawingTips[0];
  String _toolHint = '';

  static const _colors = [
    Colors.black, Colors.white, Colors.red, Colors.blue, Colors.green,
    Colors.orange, Colors.purple, Colors.pink, Colors.brown, Colors.grey,
    Colors.amber, Colors.teal, Colors.indigo, Colors.lime, Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _currentTip = _drawingTips[Random().nextInt(_drawingTips.length)];
    _updateToolHint();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<DrawingProvider>().loadDrawings());
  }

  @override
  void dispose() { _transformCtrl.dispose(); _titleCtrl.dispose(); super.dispose(); }

  void _updateToolHint() {
    switch (_currentTool) {
      case DrawingTool.pen: _toolHint = 'اسحبي للرسم بحرية';
      case DrawingTool.line: _toolHint = 'اسحبي لرسم خط مستقيم';
      case DrawingTool.rect: _toolHint = 'اسحبي لرسم مربع';
      case DrawingTool.oval: _toolHint = 'اسحبي لرسم دائرة';
      case DrawingTool.eyedropper: _toolHint = 'اضغطي على لون لاختياره';
    }
  }

  void _undo() {
    if (_strokes.isNotEmpty) setState(() => _strokes.removeLast());
    else if (_shapes.isNotEmpty) setState(() => _shapes.removeLast());
  }

  void _clear() { setState(() { _strokes.clear(); _shapes.clear(); }); }

  void _newTip() {
    setState(() {
      String tip;
      do { tip = _drawingTips[Random().nextInt(_drawingTips.length)]; } while (tip == _currentTip && _drawingTips.length > 1);
      _currentTip = tip;
    });
  }

  Future<void> _pickRefImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1200);
      final frame = await codec.getNextFrame();
      setState(() { _refImage = file; _loadedRefImage = frame.image; });
    }
  }

  Future<void> _save() async {
    if (_strokes.isEmpty && _shapes.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💾 حفظ الرسمة'),
        content: TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'اسم الرسمة (اختياري)', border: OutlineInputBorder(), hintText: 'رسمة جديدة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async { Navigator.pop(ctx); await _captureAndSave(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSave() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      final title = _titleCtrl.text.trim().isEmpty
          ? 'رسمة ${DateFormat('yyyy/MM/dd', 'ar').format(DateTime.now())}' : _titleCtrl.text.trim();
      _titleCtrl.clear();
      await context.read<DrawingProvider>().addDrawing(MyDrawing(title: title, imagePath: file.path, createdAt: DateTime.now()));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الرسمة')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
    }
  }

  Future<void> _pickColorFromCanvas(Offset localPos) async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 1);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return;
      final x = localPos.dx.toInt().clamp(0, image.width - 1);
      final y = localPos.dy.toInt().clamp(0, image.height - 1);
      final offset = (y * image.width + x) * 4;
      setState(() {
        _currentColor = Color.fromARGB(
          byteData.getUint8(offset + 3),
          byteData.getUint8(offset),
          byteData.getUint8(offset + 1),
          byteData.getUint8(offset + 2),
        );
        _isEraser = false;
        _currentTool = DrawingTool.pen;
        _updateToolHint();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 الرسم الحر'),
        actions: [
          IconButton(icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off, color: _showGrid ? AppColors.primary : null),
              onPressed: () => setState(() => _showGrid = !_showGrid), tooltip: 'شبكة'),
          IconButton(icon: Icon(_symmetryMode ? Icons.flip : Icons.flip_to_back, color: _symmetryMode ? AppColors.primary : null),
              onPressed: () => setState(() => _symmetryMode = !_symmetryMode), tooltip: 'تناظر'),
          IconButton(icon: const Icon(Icons.undo), onPressed: (_strokes.isEmpty && _shapes.isEmpty) ? null : _undo, tooltip: 'تراجع'),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: (_strokes.isEmpty && _shapes.isEmpty) ? null : _clear, tooltip: 'مسح'),
          IconButton(icon: const Icon(Icons.save_alt), onPressed: (_strokes.isEmpty && _shapes.isEmpty) ? null : _save, tooltip: 'حفظ'),
        ],
      ),
      body: Column(
        children: [
          _buildTipBar(),
          Expanded(child: _buildCanvas()),
          _buildToolSelector(),
          _buildColorBar(),
          _buildStrokeControl(),
          _buildSavedDrawings(),
        ],
      ),
    );
  }

  Widget _buildTipBar() {
    return GestureDetector(
      onTap: _newTip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: AppColors.purpleSoft.withValues(alpha: 0.3),
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(_currentTip, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
            Text('تغيير', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          transformationController: _transformCtrl,
          minScale: 1, maxScale: 5,
          child: RepaintBoundary(
            key: _canvasKey,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: 1000, height: 800,
                decoration: BoxDecoration(color: _canvasBg, borderRadius: BorderRadius.circular(12)),
                child: CustomPaint(
                  painter: _DrawingPainter(
                    strokes: _strokes, shapes: _shapes, currentStroke: _currentStroke,
                    currentShape: _currentShape, showGrid: _showGrid, symmetryMode: _symmetryMode,
                    refImage: _loadedRefImage, refOpacity: _refOpacity, canvasBg: _canvasBg,
                    cursorPos: _cursorPos, cursorColor: _currentColor, cursorWidth: _strokeWidth,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    setState(() => _cursorPos = localPos);
    if (_currentTool == DrawingTool.eyedropper) { _pickColorFromCanvas(localPos); return; }
    if (_currentTool == DrawingTool.pen) {
      _currentStroke = _DrawingStroke(
        color: _isEraser ? _canvasBg : _currentColor.withValues(alpha: _opacity),
        strokeWidth: _isEraser ? _strokeWidth * 4 : _strokeWidth,
        isEraser: _isEraser, brushType: _brushType,
      );
      _currentStroke!.points.add(localPos);
      if (_symmetryMode) _currentStroke!.points.add(Offset(1000 - localPos.dx, localPos.dy));
    } else {
      _shapeStart = localPos;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final localPos = renderBox.globalToLocal(details.globalPosition);
    setState(() => _cursorPos = localPos);
    if (_currentTool == DrawingTool.pen) {
      if (_currentStroke == null) return;
      _currentStroke!.points.add(localPos);
      if (_symmetryMode) _currentStroke!.points.add(Offset(1000 - localPos.dx, localPos.dy));
    } else if (_shapeStart != null) {
      _currentShape = _DrawingShape(
        type: _currentTool, color: _currentColor.withValues(alpha: _opacity),
        strokeWidth: _strokeWidth, start: _shapeStart!, end: localPos,
      );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _cursorPos = null);
    if (_currentStroke != null) { _strokes.add(_currentStroke!); _currentStroke = null; }
    if (_currentShape != null) { _shapes.add(_currentShape!); _currentShape = null; _shapeStart = null; }
  }

  Widget _buildToolSelector() {
    final tools = [
      (DrawingTool.pen, '✏️', 'قلم'), (DrawingTool.line, '📏', 'خط'),
      (DrawingTool.rect, '⬜', 'مربع'), (DrawingTool.oval, '⭕', 'دائرة'),
      (DrawingTool.eyedropper, '💉', 'قطارة'),
    ];
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (final (tool, emoji, label) in tools)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() { _currentTool = tool; _isEraser = false; _updateToolHint(); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: _currentTool == tool ? AppColors.blueSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(children: [
                        Text(emoji, style: TextStyle(fontSize: _currentTool == tool ? 22 : 18)),
                        Text(label, style: TextStyle(fontSize: 8, fontWeight: _currentTool == tool ? FontWeight.bold : FontWeight.normal)),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              if (_currentTool == DrawingTool.pen) ..._buildBrushSelector(),
              GestureDetector(
                onTap: _pickRefImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: _refImage != null ? AppColors.greenSoft : Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.image, size: 18, color: AppColors.primary),
                ),
              ),
              if (_refImage != null) ...[
                const SizedBox(width: 2),
                GestureDetector(onTap: () => setState(() { _refImage = null; _loadedRefImage = null; }), child: const Icon(Icons.close, size: 14, color: AppColors.error)),
                const SizedBox(width: 2),
                SizedBox(width: 50, child: Slider(value: _refOpacity, min: 0.1, max: 1, onChanged: (v) => setState(() => _refOpacity = v))),
              ],
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Text(_toolHint, style: const TextStyle(fontSize: 9, color: AppColors.textLight), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBrushSelector() {
    final brushes = [
      (BrushType.pencil, '✏️', 'رصاص'), (BrushType.marker, '🖊️', 'ماركر'), (BrushType.spray, '💨', 'رش'),
      (BrushType.calligraphy, '✒️', 'خط'), (BrushType.oil, '🖌️', 'زيت'), (BrushType.watercolor, '💧', 'مائي'), (BrushType.crayon, '🖍️', 'باستيل'),
    ];
    return brushes.expand((b) => [
      GestureDetector(
        onTap: () => setState(() => _brushType = b.$1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: _brushType == b.$1 ? AppColors.purpleSoft : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          child: Column(children: [
            Text(b.$2, style: TextStyle(fontSize: _brushType == b.$1 ? 16 : 12)),
            Text(b.$3, style: TextStyle(fontSize: 6, fontWeight: _brushType == b.$1 ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
      ),
    ]).toList();
  }

  Widget _buildColorBar() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final color in _colors)
                    GestureDetector(
                      onTap: () => setState(() { _currentColor = color; _isEraser = false; }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: _currentColor == color && !_isEraser ? 26 : 20,
                        height: _currentColor == color && !_isEraser ? 26 : 20,
                        decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle,
                          border: Border.all(color: color == Colors.white ? Colors.grey[300]! : Colors.transparent, width: 1),
                          boxShadow: _currentColor == color && !_isEraser
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 4)] : null,
                        ),
                        child: _currentColor == color && !_isEraser
                            ? Icon(Icons.check, size: color == Colors.white ? 14 : 12, color: color == Colors.white ? Colors.black : Colors.white) : null,
                      ),
                    ),
                  GestureDetector(
                    onTap: _showCustomColorPicker,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle, border: Border.all(color: Colors.grey[400]!)),
                      child: const Icon(Icons.colorize, size: 14, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _isEraser = !_isEraser),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: _isEraser ? AppColors.pinkSoft : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.auto_fix_high, size: 18, color: _isEraser ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('🎨 خلفية القماش'),
                content: Wrap(spacing: 8, runSpacing: 8, children: [
                  Colors.white, Colors.black, Colors.grey[200]!, Colors.blue[50]!, Colors.pink[50]!, Colors.amber[50]!, Colors.green[50]!, Colors.purple[50]!,
                ].map((c) => GestureDetector(
                  onTap: () { setState(() => _canvasBg = c); Navigator.pop(ctx); },
                  child: Container(width: 32, height: 32, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!))),
                )).toList()),
              ),
            ),
            child: Container(width: 24, height: 24, decoration: BoxDecoration(color: _canvasBg, shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!))),
          ),
        ],
      ),
    );
  }

  void _showCustomColorPicker() {
    double r = _currentColor.r, g = _currentColor.g, b = _currentColor.b;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('🌈 لون مخصص'),
          content: SizedBox(
            width: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 40, decoration: BoxDecoration(color: Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1), borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 12),
                _colorSlider('أحمر', r, Colors.red, (v) { r = v; setDialogState(() {}); }),
                _colorSlider('أخضر', g, Colors.green, (v) { g = v; setDialogState(() {}); }),
                _colorSlider('أزرق', b, Colors.blue, (v) { b = v; setDialogState(() {}); }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { setState(() { _currentColor = Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1); _isEraser = false; }); Navigator.pop(ctx); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('اختيار', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorSlider(String label, double val, Color color, ValueChanged<double> onChanged) {
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 11)),
      Expanded(child: Slider(value: val, min: 0, max: 1, activeColor: color, onChanged: onChanged)),
    ]);
  }

  Widget _buildStrokeControl() {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.near_me, size: 12, color: AppColors.textSecondary),
                Expanded(child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)),
                  child: Slider(value: _strokeWidth, min: 1, max: 30, onChanged: (v) => setState(() => _strokeWidth = v), activeColor: AppColors.primary),
                )),
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _currentColor),
                  child: Center(child: Container(
                    width: (_strokeWidth / 30 * 14).clamp(2.0, 14.0),
                    height: (_strokeWidth / 30 * 14).clamp(2.0, 14.0),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.opacity, size: 12, color: AppColors.textSecondary),
              SizedBox(
                width: 60,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)),
                  child: Slider(value: _opacity, min: 0.1, max: 1, onChanged: (v) => setState(() => _opacity = v), activeColor: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedDrawings() {
    return Consumer<DrawingProvider>(
      builder: (context, provider, child) {
        if (provider.drawings.isEmpty) return const SizedBox(height: 4);
        return Container(
          height: 70,
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  const Text('📂 رسوماتي', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${provider.drawings.length}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: provider.drawings.length,
                  itemBuilder: (context, i) {
                    final d = provider.drawings[i];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(d.title, style: const TextStyle(fontSize: 14)),
                            content: Image.file(File(d.imagePath)),
                            actions: [
                              TextButton(
                                onPressed: () { context.read<DrawingProvider>().deleteDrawing(d.id!); File(d.imagePath).deleteSync(); Navigator.pop(ctx); },
                                child: const Text('🗑️ حذف', style: TextStyle(color: AppColors.error)),
                              ),
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey[300]!)),
                        child: Column(children: [
                          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(5)), child: Image.file(File(d.imagePath), fit: BoxFit.cover, width: 55))),
                          Text(d.title, style: const TextStyle(fontSize: 7), overflow: TextOverflow.ellipsis, maxLines: 1),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Models ──
class _DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;
  final BrushType brushType;
  _DrawingStroke({required this.color, required this.strokeWidth, this.isEraser = false, this.brushType = BrushType.pencil}) : points = [];
}

class _DrawingShape {
  final DrawingTool type;
  final Color color;
  final double strokeWidth;
  final Offset start;
  final Offset end;
  _DrawingShape({required this.type, required this.color, required this.strokeWidth, required this.start, required this.end});
}

// ── Painter ──
class _DrawingPainter extends CustomPainter {
  final List<_DrawingStroke> strokes;
  final List<_DrawingShape> shapes;
  final _DrawingStroke? currentStroke;
  final _DrawingShape? currentShape;
  final bool showGrid; final bool symmetryMode;
  final ui.Image? refImage; final double refOpacity; final Color canvasBg;
  final Offset? cursorPos; final Color cursorColor; final double cursorWidth;

  _DrawingPainter({
    required this.strokes, this.shapes = const [], this.currentStroke, this.currentShape,
    this.showGrid = false, this.symmetryMode = false,
    this.refImage, this.refOpacity = 0.3, required this.canvasBg,
    this.cursorPos, required this.cursorColor, required this.cursorWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (refImage != null) {
      final rs = (size.width / refImage!.width).clamp(0.0, 1.0);
      final rh = (size.height / refImage!.height).clamp(0.0, 1.0);
      final s = min(rs, rh);
      final w = refImage!.width * s;
      final h = refImage!.height * s;
      canvas.drawImageRect(refImage!, Rect.fromLTWH(0, 0, refImage!.width.toDouble(), refImage!.height.toDouble()),
          Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h), Paint()..color = Colors.white.withValues(alpha: refOpacity));
    }

    if (showGrid) {
      final paint = Paint()..color = Colors.grey.withValues(alpha: 0.12)..strokeWidth = 0.5;
      const step = 30.0;
      for (double x = 0; x <= size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      for (double y = 0; y <= size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      final cp = Paint()..color = Colors.grey.withValues(alpha: 0.25)..strokeWidth = 1;
      canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), cp);
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), cp);
    }

    if (symmetryMode) {
      final sp = Paint()..color = AppColors.primary.withValues(alpha: 0.15)..strokeWidth = 1.5;
      canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), sp);
    }

    for (final s in strokes) _drawStroke(canvas, s);
    if (currentStroke != null) _drawStroke(canvas, currentStroke!);
    for (final s in shapes) _drawShape(canvas, s);
    if (currentShape != null) _drawShape(canvas, currentShape!);

    if (cursorPos != null && cursorPos!.dx >= 0 && cursorPos!.dy >= 0) {
      final cp = Paint()..color = cursorColor.withValues(alpha: 0.3)..style = PaintingStyle.fill;
      canvas.drawCircle(cursorPos!, cursorWidth / 2 + 6, cp);
      final cpb = Paint()..color = cursorColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
      canvas.drawCircle(cursorPos!, cursorWidth / 2 + 6, cpb);
    }
  }

  void _drawStroke(Canvas canvas, _DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;
    if (stroke.points.length < 2) {
      final paint = Paint()..color = stroke.color..strokeWidth = stroke.strokeWidth..strokeCap = StrokeCap.round..style = PaintingStyle.fill;
      canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint);
      return;
    }
    switch (stroke.brushType) {
      case BrushType.pencil: _drawPencil(canvas, stroke); break;
      case BrushType.marker: _drawMarker(canvas, stroke); break;
      case BrushType.spray: _drawSpray(canvas, stroke); break;
      case BrushType.calligraphy: _drawCalligraphy(canvas, stroke); break;
      case BrushType.oil: _drawOil(canvas, stroke); break;
      case BrushType.watercolor: _drawWatercolor(canvas, stroke); break;
      case BrushType.crayon: _drawCrayon(canvas, stroke); break;
    }
  }

  void _paintStroke(Canvas canvas, _DrawingStroke stroke, Paint paint) {
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      final p0 = stroke.points[i - 1];
      final p1 = stroke.points[i];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
    canvas.drawPath(path, paint);
  }

  void _drawPencil(Canvas canvas, _DrawingStroke stroke) {
    _paintStroke(canvas, stroke, Paint()
      ..color = stroke.color..strokeWidth = stroke.strokeWidth..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke);
  }

  void _drawMarker(Canvas canvas, _DrawingStroke stroke) {
    _paintStroke(canvas, stroke, Paint()
      ..color = stroke.color..strokeWidth = stroke.strokeWidth * 2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke);
  }

  void _drawSpray(Canvas canvas, _DrawingStroke stroke) {
    final rng = Random();
    final paint = Paint()..color = stroke.color;
    for (final pt in stroke.points) {
      final count = (stroke.strokeWidth * 0.6).round();
      for (int i = 0; i < count; i++) {
        final angle = rng.nextDouble() * 2 * pi;
        final radius = rng.nextDouble() * stroke.strokeWidth;
        canvas.drawCircle(Offset(pt.dx + cos(angle) * radius, pt.dy + sin(angle) * radius), rng.nextDouble() * 1.5 + 0.3, paint);
      }
    }
  }

  void _drawCalligraphy(Canvas canvas, _DrawingStroke stroke) {
    for (int i = 1; i < stroke.points.length; i++) {
      final p0 = stroke.points[i - 1];
      final p1 = stroke.points[i];
      final angle = atan2(p1.dy - p0.dy, p1.dx - p0.dx);
      final width = stroke.strokeWidth * (0.4 + 0.6 * sin(angle).abs());
      canvas.drawLine(p0, p1, Paint()..color = stroke.color..strokeWidth = width..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    }
  }

  void _drawOil(Canvas canvas, _DrawingStroke stroke) {
    final rng = Random(42);
    final basePaint = Paint()..color = stroke.color..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    for (int i = 1; i < stroke.points.length; i++) {
      final p0 = stroke.points[i - 1];
      final p1 = stroke.points[i];
      final w = stroke.strokeWidth * (0.8 + 0.4 * rng.nextDouble());
      basePaint.strokeWidth = w;
      canvas.drawLine(p0, p1, basePaint);
      if (w > 4) {
        final offset = 1.5 * (rng.nextDouble() - 0.5);
        basePaint.strokeWidth = w * 0.6;
        basePaint.color = stroke.color.withValues(alpha: stroke.color.a * 0.3);
        canvas.drawLine(Offset(p0.dx + offset, p0.dy + offset), Offset(p1.dx + offset, p1.dy + offset), basePaint);
      }
    }
  }

  void _drawWatercolor(Canvas canvas, _DrawingStroke stroke) {
    final rng = Random();
    for (int i = 1; i < stroke.points.length; i++) {
      final p0 = stroke.points[i - 1];
      final p1 = stroke.points[i];
      final alpha = rng.nextDouble() * 0.3 + 0.1;
      final w = stroke.strokeWidth * (0.7 + 0.6 * rng.nextDouble());
      canvas.drawLine(p0, p1, Paint()
        ..color = stroke.color.withValues(alpha: alpha * stroke.color.a)
        ..strokeWidth = w..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
    }
  }

  void _drawCrayon(Canvas canvas, _DrawingStroke stroke) {
    final rng = Random();
    for (int i = 1; i < stroke.points.length; i++) {
      final p0 = stroke.points[i - 1];
      final p1 = stroke.points[i];
      final w = stroke.strokeWidth * (0.6 + 0.8 * rng.nextDouble());
      final dx = (rng.nextDouble() - 0.5) * 2;
      final dy = (rng.nextDouble() - 0.5) * 2;
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.color.a * 0.7)
        ..strokeWidth = w..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(p0.dx + dx, p0.dy + dy), Offset(p1.dx + dx, p1.dy + dy), paint);
      if (rng.nextDouble() > 0.5) {
        paint.strokeWidth = w * 0.4;
        paint.color = stroke.color.withValues(alpha: stroke.color.a * 0.25);
        canvas.drawLine(Offset(p0.dx - dx, p0.dy - dy), Offset(p1.dx - dx, p1.dy - dy), paint);
      }
    }
  }

  void _drawShape(Canvas canvas, _DrawingShape shape) {
    final paint = Paint()..color = shape.color..strokeWidth = shape.strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final rect = Rect.fromPoints(shape.start, shape.end);
    switch (shape.type) {
      case DrawingTool.line: canvas.drawLine(shape.start, shape.end, paint); break;
      case DrawingTool.rect: canvas.drawRect(rect, paint); break;
      case DrawingTool.oval: canvas.drawOval(rect, paint); break;
      default: break;
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
