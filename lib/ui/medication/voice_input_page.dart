import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/app_theme.dart';

class VoiceInputPage extends ConsumerStatefulWidget {
  const VoiceInputPage({super.key});

  @override
  ConsumerState<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends ConsumerState<VoiceInputPage>
    with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  bool _hasPermission = false;

  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    _hasPermission = await _speechToText.hasPermission;
    setState(() {});
  }

  void _startListening() async {
    _hasPermission = await _speechToText.hasPermission;
    if (!_hasPermission) {
      final available = await _speechToText.initialize();
      _hasPermission = await _speechToText.hasPermission;
      setState(() {});
      if (!_hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
        return;
      }
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech services unavailable')),
        );
        return;
      }
    }

    if (!_speechToText.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech services unavailable')),
      );
      return;
    }

    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mic,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Describe your medication',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell me the name, dosage, and how often you take it',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Voice Visualizer
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Voice Animation
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(200, 200),
                          painter: VoiceVisualizerPainter(
                            isListening: _speechToText.isListening,
                            animation: _waveController,
                            pulseAnimation: _pulseController,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Status Text
                    Text(
                      _speechToText.isListening
                          ? 'Listening...'
                          : !_hasPermission
                              ? 'Microphone permission denied'
                              : _speechToText.isAvailable
                                  ? 'Tap the microphone to start'
                                  : 'Speech not available',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Recognized Text
                    if (_wordsSpoken.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'You said:',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _wordsSpoken,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            if (_confidenceLevel > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Confidence: ${(_confidenceLevel * 100).toInt()}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            SafeArea(
              child: Column(
                children: [
                  // Microphone Button
                  GestureDetector(
                    onTap: _speechToText.isNotListening ? _startListening : _stopListening,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _speechToText.isListening 
                            ? AppTheme.errorColor 
                            : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_speechToText.isListening 
                                ? AppTheme.errorColor 
                                : AppTheme.primaryColor).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: _speechToText.isListening ? 10 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _speechToText.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Continue Button
                  if (_wordsSpoken.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _processSpeechInput,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Try Again Button
                  if (_wordsSpoken.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _wordsSpoken = "";
                          _confidenceLevel = 0;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processSpeechInput() {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processing voice input...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close processing dialog
      
      // Navigate to confirmation with parsed data
      context.go('/medication/confirm', extra: {
        'name': 'Aspirin', // Mock parsed data
        'dosage': 81.0,
        'unit': 'mg',
        'form': 'tablet',
        'frequency': 'Once daily',
        'voiceInput': _wordsSpoken,
        'confidence': _confidenceLevel,
      });
    });
  }
}

class VoiceVisualizerPainter extends CustomPainter {
  final bool isListening;
  final Animation<double> animation;
  final Animation<double> pulseAnimation;

  VoiceVisualizerPainter({
    required this.isListening,
    required this.animation,
    required this.pulseAnimation,
  }) : super(repaint: Listenable.merge([animation, pulseAnimation]));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    if (isListening) {
      _drawListeningAnimation(canvas, center, radius);
    } else {
      _drawIdleState(canvas, center, radius);
    }
  }

  void _drawListeningAnimation(Canvas canvas, Offset center, double radius) {
    // Draw animated sound waves
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 1; i <= 3; i++) {
      final waveRadius = radius + (i * 30) + (animation.value * 20);
      final opacity = (1.0 - animation.value) * 0.7;
      
      wavePaint.color = AppTheme.primaryColor.withOpacity(opacity);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }

    // Draw center microphone
    _drawMicrophone(canvas, center, radius, AppTheme.primaryColor);
  }

  void _drawIdleState(Canvas canvas, Offset center, double radius) {
    // Draw pulsing microphone
    final pulseRadius = radius + (pulseAnimation.value * 10);
    
    final pulsePaint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3 + (pulseAnimation.value * 0.4))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, pulseRadius, pulsePaint);
    
    // Draw center microphone
    _drawMicrophone(canvas, center, radius * 0.8, AppTheme.primaryColor);
  }

  void _drawMicrophone(Canvas canvas, Offset center, double radius, Color color) {
    final micPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw microphone body
    final micRect = Rect.fromCenter(
      center: center,
      width: radius,
      height: radius * 1.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(micRect, const Radius.circular(20)),
      micPaint,
    );

    // Draw microphone stand
    final standPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, micRect.bottom),
      Offset(center.dx, micRect.bottom + 20),
      standPaint,
    );

    canvas.drawLine(
      Offset(center.dx - 15, micRect.bottom + 20),
      Offset(center.dx + 15, micRect.bottom + 20),
      standPaint,
    );
  }

  @override
  bool shouldRepaint(VoiceVisualizerPainter oldDelegate) {
    return isListening != oldDelegate.isListening ||
           animation != oldDelegate.animation ||
           pulseAnimation != oldDelegate.pulseAnimation;
  }
}