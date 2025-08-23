import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../widgets/cylindrical_overlay.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isFlashOn = false;
  String _scanMode = 'cylindrical'; // cylindrical, single, multiple

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();

        setState(() {
          _isInitialized = true;
        });
      } else {
        debugPrint('No cameras available');
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Camera Unavailable'),
              content: const Text('No cameras available on this device.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Error'),
            content: const Text(
              'Failed to initialize the camera. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          
          // Overlay
          if (_scanMode == 'cylindrical')
            const Positioned.fill(
              child: CylindricalOverlay(),
            ),
          
          // Top Controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Flash Toggle
                    IconButton(
                      onPressed: _toggleFlash,
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    // Scan Mode Toggle
                    IconButton(
                      onPressed: _showScanModeSelector,
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _getInstructionTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getInstructionText(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    IconButton(
                      onPressed: _selectFromGallery,
                      icon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    
                    // Capture Button
                    GestureDetector(
                      onTap: _scanMode == 'cylindrical' 
                          ? (_isRecording ? _stopRecording : _startRecording)
                          : _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isRecording ? AppTheme.errorColor : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          _scanMode == 'cylindrical'
                              ? (_isRecording ? Icons.stop : Icons.videocam)
                              : Icons.camera_alt,
                          color: _isRecording ? Colors.white : Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                    
                    // Switch Camera Button (placeholder)
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.switch_camera,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInstructionTitle() {
    switch (_scanMode) {
      case 'cylindrical':
        return 'Rotate the bottle slowly';
      case 'single':
        return 'Center the label in frame';
      case 'multiple':
        return 'Take multiple photos';
      default:
        return 'Scan medication label';
    }
  }

  String _getInstructionText() {
    switch (_scanMode) {
      case 'cylindrical':
        return 'Hold your phone steady and slowly rotate the bottle 360° while recording';
      case 'single':
        return 'Make sure the medication label is clearly visible and well-lit';
      case 'multiple':
        return 'Take photos from different angles to capture all label information';
      default:
        return 'Follow the on-screen guidance';
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  void _showScanModeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Scan Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              _ScanModeOption(
                title: 'Cylindrical Scan',
                subtitle: 'Record video while rotating bottle (Recommended)',
                icon: Icons.videocam,
                isSelected: _scanMode == 'cylindrical',
                onTap: () {
                  setState(() {
                    _scanMode = 'cylindrical';
                  });
                  Navigator.pop(context);
                },
              ),
              
              _ScanModeOption(
                title: 'Single Photo',
                subtitle: 'Take one photo of the label',
                icon: Icons.camera_alt,
                isSelected: _scanMode == 'single',
                onTap: () {
                  setState(() {
                    _scanMode = 'single';
                  });
                  Navigator.pop(context);
                },
              ),
              
              _ScanModeOption(
                title: 'Multiple Photos',
                subtitle: 'Take several photos from different angles',
                icon: Icons.photo_library,
                isSelected: _scanMode == 'multiple',
                onTap: () {
                  setState(() {
                    _scanMode = 'multiple';
                  });
                  Navigator.pop(context);
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_controller != null && !_isRecording) {
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        // Handle recording error
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_controller != null && _isRecording) {
      try {
        final video = await _controller!.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        
        // Process video for cylindrical unwrapping
        _processVideo(video.path);
      } catch (e) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null) {
      try {
        final image = await _controller!.takePicture();
        _processImage(image.path);
      } catch (e) {
        // Handle capture error
      }
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _processImage(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error selecting image from gallery: $e');
    }
  }

  void _processVideo(String videoPath) async {
    _showProcessingDialog();
    try {
      final data =
          await ref.read(medicationServiceProvider).parseLabel(videoPath);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/medication/confirm', extra: data);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parsing label: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _processImage(String imagePath) async {
    _showProcessingDialog();
    try {
      final data =
          await ref.read(medicationServiceProvider).parseLabel(imagePath);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/medication/confirm', extra: data);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error parsing label: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showProcessingDialog() {
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
              'Processing medication label...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScanModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected 
          ? Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
            )
          : null,
      onTap: onTap,
    );
  }
}