import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:webview_all/webview_all.dart';

class InteractiveBodyMap extends StatefulWidget {
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;

  const InteractiveBodyMap({
    super.key,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  @override
  State<InteractiveBodyMap> createState() => _InteractiveBodyMapState();
}

class _InteractiveBodyMapState extends State<InteractiveBodyMap> {
  WebViewController? _controller;
  bool _loading = true;
  int? _progress;
  String? _loadError;
  Timer? _loadTimeout;
  int _viewerAttempt = 0;

  @override
  void initState() {
    super.initState();
    _createViewer();
  }

  Future<void> _createViewer() async {
    if (WebViewPlatform.instance == null) {
      _showLoadError(
        'This app build does not have a WebView available. '
        'Choose an area below or reinstall the app.',
      );
      return;
    }

    _startLoadTimeout();
    final attempt = _viewerAttempt;
    final controller = WebViewController();
    _controller = controller;
    if (mounted) setState(() {});

    try {
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(const Color(0xFFF2F7F7));
      await controller.addJavaScriptChannel(
        'Mediora',
        onMessageReceived: (message) {
          if (!mounted || attempt != _viewerAttempt) return;
          _handleViewerMessage(message.message);
        },
      );
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (attempt == _viewerAttempt) {
              _selectArea(widget.selectedArea);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true &&
                mounted &&
                attempt == _viewerAttempt) {
              _showLoadError(
                'The 3D anatomy viewer could not load: ${error.description}',
              );
            }
          },
        ),
      );
      await controller.loadHtmlString(
        _viewerHtml,
        baseUrl: 'https://mediora.app',
      );
    } catch (error) {
      if (attempt == _viewerAttempt) {
        _showLoadError('The 3D anatomy viewer could not start: $error');
      }
    }
  }

  void _handleViewerMessage(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected an anatomy viewer event.');
      }
      final area = decoded['area'];
      if (area is String && cats.containsKey(area)) {
        widget.onAreaSelected(area);
      }
      final progress = decoded['progress'];
      if (progress is int && progress >= 0 && progress <= 100 && mounted) {
        setState(() => _progress = progress);
      }
      if (decoded['ready'] == true && mounted) {
        _loadTimeout?.cancel();
        setState(() {
          _loading = false;
          _loadError = null;
          _progress = null;
        });
      }
      if (decoded['error'] is String) {
        _showLoadError(decoded['error'] as String);
      }
    } on FormatException catch (error) {
      _showLoadError('Invalid response from the 3D anatomy viewer: $error');
    }
  }

  void _showLoadError(String message) {
    _loadTimeout?.cancel();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _progress = null;
      _loadError = message;
    });
  }

  void _retryViewer() {
    _loadTimeout?.cancel();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _progress = null;
      _loadError = null;
      _viewerAttempt++;
      _controller = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _createViewer();
    });
  }

  void _startLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(minutes: 4), () {
      if (!mounted || !_loading) return;
      _showLoadError(
        'The anatomy files are taking too long to download. '
        'Check your connection and try again.',
      );
    });
  }

  @override
  void didUpdateWidget(covariant InteractiveBodyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedArea != widget.selectedArea) {
      _selectArea(widget.selectedArea);
    }
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    super.dispose();
  }

  void _selectArea(String area) {
    final encodedArea = jsonEncode(area);
    _controller?.runJavaScript(
      'if (typeof window.setMedioraArea === "function") '
      'window.setMedioraArea($encodedArea)',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Container(
      height: 350,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDCE8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141A4550),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null)
            WebViewWidget(
              key: ValueKey(_viewerAttempt),
              controller: controller,
            ),
          if (_loading && _loadError == null) _loadingOverlay,
          if (_loadError case final error?) _errorOverlay(error),
        ],
      ),
    );
  }

  Widget get _loadingOverlay => ColoredBox(
        color: const Color(0xFFF2F7F7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF32867D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _progress == null
                    ? 'Loading 3D anatomy…'
                    : 'Loading 3D anatomy · $_progress%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF536D75),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'First load downloads the anatomy model.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF71838A), fontSize: 11),
              ),
            ],
          ),
        ),
      );

  Widget _errorOverlay(String error) => ColoredBox(
        color: const Color(0xFFF2F7F7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.view_in_ar_rounded,
                  color: Color(0xFF32867D),
                  size: 32,
                ),
                const SizedBox(height: 6),
                const Text(
                  '3D anatomy is unavailable',
                  style: TextStyle(
                    color: Color(0xFF253B44),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF71838A),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                FilledButton.tonalIcon(
                  onPressed: _retryViewer,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try again'),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: 0,
                  children: [
                    for (final entry in cats.entries)
                      ActionChip(
                        tooltip: entry.key,
                        avatar: Icon(entry.value, size: 15),
                        label: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 10),
                        ),
                        onPressed: () => widget.onAreaSelected(entry.key),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

const _viewerHtml = r'''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <meta name="color-scheme" content="light">
  <style>
    * { box-sizing: border-box; }
    html, body { width:100%; height:100%; margin:0; overflow:hidden; }
    body { background:radial-gradient(ellipse at 50% 44%,#fff 0%,#f2f7f7 65%,#e7efef 100%); color:#425b64; font:12px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }
    canvas { width:100%; height:100%; display:block; touch-action:none; }
    #status { position:absolute;top:10px;left:10px;max-width:72%;padding:7px 10px;border:1px solid #dce8e8;border-radius:999px;background:#ffffffdb;font-size:10px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
    #hint { position:absolute;bottom:27px;left:50%;transform:translateX(-50%);white-space:nowrap;padding:7px 11px;border-radius:999px;color:#587078;background:#ffffffdb;font-size:10px;box-shadow:0 3px 12px #20414814;pointer-events:none; }
    #credit { position:absolute;bottom:7px;left:0;right:0;text-align:center;color:#839399;font-size:8px;pointer-events:none; }
    #reset { position:absolute;top:8px;right:9px;width:32px;height:32px;border:1px solid #dce8e8;border-radius:50%;background:#ffffffd9;color:#47646c;font-size:16px; }
  </style>
  <script>
    window.reportMedioraError = function(message) {
      const status = document.getElementById('status');
      if (status) { status.textContent = 'Anatomy viewer error'; status.style.color = '#a7443d'; }
      if (window.Mediora && window.Mediora.postMessage) {
        window.Mediora.postMessage(JSON.stringify({error:message}));
      }
    };
    window.addEventListener('error', event => window.reportMedioraError(event.message || 'The 3D viewer could not start.'));
    window.addEventListener('unhandledrejection', event => window.reportMedioraError(String(event.reason || 'The 3D viewer could not start.')));
  </script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/build/three.min.js"
    onerror="window.reportMedioraError('Three.js could not be downloaded. Check your internet connection.')"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"
    onerror="window.reportMedioraError('The 3D camera controls could not be downloaded.')"></script>
</head>
<body>
  <div id="status">Preparing anatomy model…</div>
  <button id="reset" aria-label="Reset model view" title="Reset view">↻</button>
  <div id="hint">Drag to rotate · pinch to zoom · tap a body part</div>
  <div id="credit">BodyParts3D 4.0 © Database Center for Life Science · CC BY 4.0</div>
  <script>
  (function() {
    'use strict';
    const REVISION = '1c38bf35c254a891200d3cedecfd57abebe83d8d';
    const ROOT = 'https://raw.githubusercontent.com/ashemag/human-atlas/' + REVISION + '/public';
    const SYSTEM_COLORS = {
      skeletal:'#e2d9ba', muscular:'#a85b50', cardiac:'#b96760',
      sensory:'#b0c8ce', arterial:'#c05245', venous:'#527c9f',
      nervous:'#d8b565', respiratory:'#b98991', digestive:'#b8916b',
      urinary:'#b47961', lymphatic:'#879f7c', endocrine:'#c5a09a',
      reproductive:'#bda098', integumentary:'#ba9b7d', connective:'#aec3bb'
    };
    const SYSTEM_NAMES = {
      skeletal:'Skeleton', muscular:'Muscles', cardiac:'Heart',
      sensory:'Sensory organs', arterial:'Arteries', venous:'Veins',
      nervous:'Nervous system', respiratory:'Respiratory', digestive:'Digestive',
      urinary:'Urinary', lymphatic:'Lymphatic', endocrine:'Endocrine',
      reproductive:'Reproductive', integumentary:'Body surface',
      connective:'Connective tissue'
    };
    const DEFAULT_SYSTEMS = new Set([
      'cardiac','sensory','skeletal','muscular','arterial','venous',
      'nervous','respiratory','digestive','urinary','lymphatic',
      'endocrine','reproductive','connective'
    ]);
    const status = document.getElementById('status');
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0xf2f7f7);
    const camera = new THREE.PerspectiveCamera(34, innerWidth / innerHeight, 0.005, 100);
    let renderer;
    try {
      renderer = new THREE.WebGLRenderer({antialias:true, alpha:false, powerPreference:'high-performance'});
    } catch (error) {
      window.reportMedioraError('This device could not start WebGL: ' + error.message);
      return;
    }
    renderer.setPixelRatio(Math.min(devicePixelRatio || 1, innerWidth < 768 ? 1.5 : 2));
    renderer.setSize(innerWidth, innerHeight);
    renderer.setClearColor(0xf2f7f7);
    renderer.outputEncoding = THREE.sRGBEncoding;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.12;
    document.body.prepend(renderer.domElement);
    scene.add(new THREE.HemisphereLight(0xffffff, 0xa7acb2, 1.15));
    const keyLight = new THREE.DirectionalLight(0xfffaf4, 2.25);
    keyLight.position.set(-2, 4, 3);
    scene.add(keyLight);
    const rimLight = new THREE.DirectionalLight(0xe9f0ff, 1.5);
    rimLight.position.set(2, 2, -3);
    scene.add(rimLight);
    const controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.target.set(0, 0.85, 0);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;
    controls.enablePan = false;
    controls.minDistance = 0.18;
    controls.maxDistance = 8;
    controls.maxPolarAngle = Math.PI * 0.96;
    let meshes = [];
    let currentSelection = null;
    let currentArea = '';
    const raycaster = new THREE.Raycaster();
    const pointer = new THREE.Vector2();
    const pointerDown = new THREE.Vector2();
    let dragged = false;

    function reportProgress(value) {
      status.textContent = 'Loading anatomy · ' + value + '%';
      if (window.Mediora && window.Mediora.postMessage) {
        window.Mediora.postMessage(JSON.stringify({progress:value}));
      }
    }

    async function fetchManifest() {
      const response = await fetch(ROOT + '/models/atlas.json');
      if (!response.ok) throw new Error('Anatomy manifest download failed (' + response.status + ').');
      const manifest = await response.json();
      if (!Array.isArray(manifest.parts) || !Array.isArray(manifest.chunks) ||
          manifest.parts.length === 0 || manifest.chunks.length === 0) {
        throw new Error('The Human Atlas anatomy manifest is incomplete.');
      }
      return manifest;
    }

    async function fetchChunk(chunk) {
      const compressedUrl = ROOT + (chunk.gzip || chunk.url);
      const response = await fetch(compressedUrl);
      if (!response.ok) throw new Error('An anatomy model part could not be downloaded (' + response.status + ').');
      const payload = await response.arrayBuffer();
      const isGzip = payload.byteLength >= 2 &&
        new Uint8Array(payload, 0, 2)[0] === 0x1f &&
        new Uint8Array(payload, 0, 2)[1] === 0x8b;
      let buffer = payload;
      if (isGzip) {
        if (typeof DecompressionStream === 'undefined') {
          const fallback = await fetch(ROOT + chunk.url);
          if (!fallback.ok) throw new Error('This device cannot decompress the anatomy model.');
          buffer = await fallback.arrayBuffer();
        } else {
          buffer = await new Response(
            new Blob([payload]).stream().pipeThrough(new DecompressionStream('gzip'))
          ).arrayBuffer();
        }
      }
      if (buffer.byteLength !== chunk.bytes) {
        throw new Error('An anatomy model part was incomplete. Try reloading the viewer.');
      }
      return buffer;
    }

    function makeBuffers(manifest) {
      function linearByte(value) {
        const channel = value / 255;
        const linear = channel <= 0.04045
          ? channel / 12.92
          : Math.pow((channel + 0.055) / 1.055, 2.4);
        return Math.round(linear * 255);
      }
      const groups = {};
      for (const system of Object.keys(SYSTEM_COLORS)) {
        const parts = manifest.parts.filter(part => part.system === system);
        if (!parts.length) continue;
        const vertexCount = parts.reduce((total, part) => total + part.vertexCount, 0);
        const indexCount = parts.reduce((total, part) => total + part.indexCount, 0);
        const hex = parseInt(SYSTEM_COLORS[system].slice(1), 16);
        const color = [
          linearByte((hex >> 16) & 255),
          linearByte((hex >> 8) & 255),
          linearByte(hex & 255)
        ];
        const colors = new Uint8Array(vertexCount * 3);
        for (let i = 0; i < vertexCount; i++) {
          const offset = i * 3;
          colors[offset] = color[0];
          colors[offset + 1] = color[1];
          colors[offset + 2] = color[2];
        }
        groups[system] = {
          positions: new Float32Array(vertexCount * 3),
          normals: new Int16Array(vertexCount * 3),
          colors: colors,
          indices: new Uint32Array(indexCount),
          vertexOffset: 0,
          indexOffset: 0,
          ranges: []
        };
      }
      return groups;
    }

    function appendChunk(manifest, chunkIndex, buffer, groups) {
      for (const part of manifest.parts) {
        if (part.chunk !== chunkIndex) continue;
        const target = groups[part.system];
        if (!target) continue;
        const vertexStart = target.vertexOffset;
        const indexStart = target.indexOffset;
        const vertexLength = part.vertexCount * 3;
        const sourcePositions = new Float32Array(buffer, part.positions, vertexLength);
        const sourceNormals = new Int16Array(buffer, part.normals, vertexLength);
        const sourceIndices = new Uint32Array(buffer, part.indices, part.indexCount);
        target.positions.set(sourcePositions, vertexStart * 3);
        target.normals.set(sourceNormals, vertexStart * 3);
        for (let i = 0; i < part.indexCount; i++) {
          target.indices[indexStart + i] = sourceIndices[i] + vertexStart;
        }
        target.ranges.push({
          faceStart: indexStart / 3,
          faceEnd: (indexStart + part.indexCount) / 3,
          vertexStart: vertexStart,
          vertexCount: part.vertexCount,
          name: part.name,
          system: part.system,
          bounds: part.bounds
        });
        target.vertexOffset += part.vertexCount;
        target.indexOffset += part.indexCount;
      }
    }

    function makeSceneMeshes(groups) {
      for (const system of Object.keys(groups)) {
        const data = groups[system];
        data.ranges.sort((a, b) => a.faceStart - b.faceStart);
        const geometry = new THREE.BufferGeometry();
        geometry.setAttribute('position', new THREE.BufferAttribute(data.positions, 3));
        geometry.setAttribute('normal', new THREE.BufferAttribute(data.normals, 3, true));
        geometry.setAttribute('color', new THREE.BufferAttribute(data.colors, 3, true));
        geometry.setIndex(new THREE.BufferAttribute(data.indices, 1));
        geometry.computeBoundingSphere();
        const surface = system === 'integumentary';
        const material = new THREE.MeshStandardMaterial({
          vertexColors:true,
          metalness:0.02,
          roughness:0.66,
          side:THREE.DoubleSide,
          transparent:surface,
          opacity:surface ? 0.12 : 1,
          depthWrite:!surface
        });
        const mesh = new THREE.Mesh(geometry, material);
        mesh.userData.system = system;
        mesh.userData.ranges = data.ranges;
        mesh.visible = DEFAULT_SYSTEMS.has(system);
        mesh.frustumCulled = false;
        scene.add(mesh);
        meshes.push(mesh);
      }
    }

    function classify(name, system, bounds) {
      const text = name.toLowerCase().replace(/[_-]/g, ' ');
      if (/(head|skull|brain|face|eye|ear|nose|mouth|tongue|neck|cranial|tooth|teeth)/.test(text)) return 'Head & Neck';
      if (/(thorax|thoracic|chest|heart|lung|rib|sternum|breast|pulmonary|diaphragm|sternocostal|pectoral|intercostal|costal)/.test(text)) return 'Chest & Breathing';
      if (/(abdomen|abdominal|stomach|liver|kidney|intestin|digest|pelvi|bladder|colon|pancrea|spleen|ureter)/.test(text)) return 'Abdomen & Digestion';
      if (/(skin|hair|cutaneous|derm)/.test(text) || system === 'integumentary') return 'Skin & Hair';
      if (system === 'sensory') return 'Head & Neck';
      if (system === 'cardiac' || system === 'respiratory') return 'Chest & Breathing';
      if (system === 'digestive' || system === 'urinary' || system === 'reproductive') return 'Abdomen & Digestion';
      if (system === 'integumentary') return 'Skin & Hair';
      if (/(limb|arm|brachial|forearm|biceps|triceps|hand|wrist|finger|palm|carpal|metacarpal|phalange|thigh|leg|knee|tibia|fibula|foot|ankle|tarsal|patella|hip|gluteal|quadriceps|hamstring|joint|articular|scapula|clavicle|elbow|humer|radius|ulna|femur)/.test(text)) return 'Muscles & Joints';
      const relativeY = (bounds[0][1] + bounds[1][1]) * 0.5;
      if (relativeY > 1.48) return 'Head & Neck';
      if (relativeY > 1.12) return 'Chest & Breathing';
      if (relativeY > 0.78) return 'Abdomen & Digestion';
      return 'Muscles & Joints';
    }

    function findRange(ranges, faceIndex) {
      let low = 0;
      let high = ranges.length - 1;
      while (low <= high) {
        const mid = (low + high) >> 1;
        const range = ranges[mid];
        if (faceIndex < range.faceStart) high = mid - 1;
        else if (faceIndex >= range.faceEnd) low = mid + 1;
        else return range;
      }
      return null;
    }

    function selectPart(mesh, range) {
      if (currentSelection) {
        currentSelection.mesh.geometry.attributes.color.array.set(
          currentSelection.original,
          currentSelection.start * 3
        );
        currentSelection.mesh.geometry.attributes.color.needsUpdate = true;
      }
      const colors = mesh.geometry.attributes.color.array;
      const start = range.vertexStart * 3;
      const end = (range.vertexStart + range.vertexCount) * 3;
      const original = colors.slice(start, end);
      const highlight = [8, 149, 117];
      for (let i = start; i < end; i += 3) {
        colors[i] = highlight[0];
        colors[i + 1] = highlight[1];
        colors[i + 2] = highlight[2];
      }
      mesh.geometry.attributes.color.needsUpdate = true;
      currentSelection = {
        mesh:mesh,
        start:range.vertexStart,
        original:original
      };
      const area = classify(range.name, range.system, range.bounds);
      status.textContent = range.name + ' · ' + area;
      if (window.Mediora && window.Mediora.postMessage) {
        window.Mediora.postMessage(JSON.stringify({area:area, structure:range.name}));
      }
    }

    async function start() {
      if (!window.THREE || !THREE.OrbitControls) {
        throw new Error('The 3D rendering scripts did not load. Check your internet connection.');
      }
      const manifest = await fetchManifest();
      const groups = makeBuffers(manifest);
      let completed = 0;
      let cursor = 0;
      const workers = Array.from({length:3}, async function() {
        while (cursor < manifest.chunks.length) {
          const chunkIndex = cursor++;
          const buffer = await fetchChunk(manifest.chunks[chunkIndex]);
          appendChunk(manifest, chunkIndex, buffer, groups);
          completed++;
          reportProgress(Math.round(completed * 100 / manifest.chunks.length));
        }
      });
      await Promise.all(workers);
      makeSceneMeshes(groups);
      camera.position.set(1.4, 1.05, 3.6);
      controls.target.set(0, 0.85, 0);
      controls.update();
      status.textContent = 'Tap a body part to see related symptoms';
      if (window.Mediora && window.Mediora.postMessage) {
        window.Mediora.postMessage(JSON.stringify({ready:true}));
      }
    }

    renderer.domElement.addEventListener('pointerdown', function(event) {
      pointerDown.set(event.clientX, event.clientY);
      dragged = false;
    });
    renderer.domElement.addEventListener('pointermove', function(event) {
      if (Math.hypot(event.clientX - pointerDown.x, event.clientY - pointerDown.y) > 7) dragged = true;
    });
    renderer.domElement.addEventListener('pointerup', function(event) {
      if (dragged || meshes.length === 0) return;
      const rect = renderer.domElement.getBoundingClientRect();
      pointer.set(
        ((event.clientX - rect.left) / rect.width) * 2 - 1,
        -((event.clientY - rect.top) / rect.height) * 2 + 1
      );
      camera.updateMatrixWorld(true);
      raycaster.setFromCamera(pointer, camera);
      const visibleMeshes = meshes.filter(function(mesh) { return mesh.visible; });
      const hit = raycaster.intersectObjects(visibleMeshes, false)[0];
      if (!hit || !hit.object.userData.ranges || hit.faceIndex === undefined) return;
      const range = findRange(hit.object.userData.ranges, hit.faceIndex);
      if (range) selectPart(hit.object, range);
    });
    document.getElementById('reset').addEventListener('click', function() {
      camera.position.set(1.4, 1.05, 3.6);
      controls.target.set(0, 0.85, 0);
      controls.update();
    });
    window.setMedioraArea = function(area) {
      currentArea = area;
      if (meshes.length === 0) return;
      if (!currentSelection) status.textContent = 'Tap a body part · ' + currentArea;
    };
    window.addEventListener('resize', function() {
      camera.aspect = innerWidth / innerHeight;
      camera.updateProjectionMatrix();
      renderer.setPixelRatio(Math.min(devicePixelRatio || 1, innerWidth < 768 ? 1.5 : 2));
      renderer.setSize(innerWidth, innerHeight);
    });
    renderer.setAnimationLoop(function() {
      controls.update();
      renderer.render(scene, camera);
    });
    start().catch(function(error) {
      console.error('Human Atlas model load failed', error);
      window.reportMedioraError(error && error.message ? error.message : 'Could not load the anatomy model.');
    });
  })();
  </script>
</body>
</html>
''';
