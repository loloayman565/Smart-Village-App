import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home Control',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121421),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. شاشة تسجيل الدخول (Login Screen)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  final String correctUsername = "admin";
  final String correctPassword = "1234";

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == correctUsername && password == correctPassword) {
      setState(() {
        _errorMessage = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SmartHomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2238),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: const Icon(
                    Icons.home_work,
                    size: 60,
                    color: Colors.blueAccent,
                  ),
                ),
              
                const SizedBox(height: 20),
                const Text(
                  'Smart Home Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يرجى تسجيل الدخول للتحكم بالنظام',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E2238),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E2238),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. شاشة لوحة التحكم الرئيسية (Smart Home Dashboard)
// ==========================================
class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  bool isDoorOpen = false;     // Servo Motor (Door)
  bool isWindowOpen = false;   // Servo Motor (Window)
  bool isFanOn = false;        // DC Motor / Fan
  double fanSpeed = 128.0;     // Fan Speed (PWM 0-255)
  bool isLightOn = false;      // Lighting Control
  bool isPvActive = false;     // PV / Solar Panel Control

  // ==========================================
  // متغيرات ودوال البلوتوث
  // ==========================================
  BluetoothConnection? connection;
  bool isConnected = false;

  void _showBluetoothDialog(BuildContext context) async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print("خطأ في جلب الأجهزة: $e");
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2238),
          title: const Text(
            'اختر جهاز الـ ESP32',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 220,
            child: devices.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد أجهزة مقترنة.\nيرجى الاقتران بـ ESP32 من إعدادات البلوتوث أولاً.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.bluetooth, color: Colors.blueAccent),
                        title: Text(
                          devices[index].name ?? "جهاز غير معروف",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          devices[index].address,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _connectToDevice(devices[index]);
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الاتصال بنجاح بـ ${device.name} 🎉')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الاتصال بالجهاز: $e')),
      );
    }
  }

  // دالة إرسال الأوامر عبر البلوتوث للـ ESP32
  void _sendCommand(String command) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode("$command\n")));
      await connection!.output.allSent;
    }
  }
  // ==========================================

  @override
  Widget build(BuildContext context) {
    int activeDevices = (isDoorOpen ? 1 : 0) +
        (isWindowOpen ? 1 : 0) +
        (isFanOn ? 1 : 0) +
        (isLightOn ? 1 : 0) +
        (isPvActive ? 1 : 0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini Header مع أزرار البلوتوث وتسجيل الخروج
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Home 👋',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ESP32 / Arduino Dashboard',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // زر البلوتوث (يتغير لونه حسب حالة الاتصال)
                      IconButton(
                        icon: Icon(
                          isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: isConnected ? Colors.greenAccent : Colors.redAccent,
                        ),
                        onPressed: () {
                          _showBluetoothDialog(context);
                        },
                      ),
                      // زر تسجيل الخروج
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () {
                          if (connection != null && connection!.isConnected) {
                            connection!.close();
                          }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Compact Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Status',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$activeDevices Active Actuators',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.bolt, color: Colors.amberAccent, size: 26),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Hardware Control Panel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Control Cards Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Door Card
                  SizedBox(
                    width: 170,
                    height: 120,
                    child: DeviceCard(
                      title: 'Door (Servo)',
                      subtitle: isDoorOpen ? '90° Open' : '0° Closed',
                      icon: Icons.door_front_door,
                      isOn: isDoorOpen,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        setState(() {
                          isDoorOpen = val;
                        });
                        _sendCommand("DOOR:${val ? 1 : 0}");
                      },
                    ),
                  ),
                  // Window Card
                  SizedBox(
                    width: 170,
                    height: 120,
                    child: DeviceCard(
                      title: 'Window (Servo)',
                      subtitle: isWindowOpen ? '90° Open' : '0° Closed',
                      icon: Icons.window,
                      isOn: isWindowOpen,
                      activeColor: Colors.cyanAccent,
                      onChanged: (val) {
                        setState(() {
                          isWindowOpen = val;
                        });
                        _sendCommand("WINDOW:${val ? 1 : 0}");
                      },
                    ),
                  ),
                  // Lighting Card
                  SizedBox(
                    width: 170,
                    height: 120,
                    child: DeviceCard(
                      title: 'Lighting',
                      subtitle: isLightOn ? 'ON' : 'OFF',
                      icon: Icons.lightbulb,
                      isOn: isLightOn,
                      activeColor: Colors.yellowAccent,
                      onChanged: (val) {
                        setState(() {
                          isLightOn = val;
                        });
                        _sendCommand("LIGHT:${val ? 1 : 0}");
                      },
                    ),
                  ),
                  // PV System Card
                  SizedBox(
                    width: 170,
                    height: 120,
                    child: DeviceCard(
                      title: 'PV System',
                      subtitle: isPvActive ? 'Generating' : 'Idle',
                      icon: Icons.solar_power,
                      isOn: isPvActive,
                      activeColor: Colors.orangeAccent,
                      onChanged: (val) {
                        setState(() {
                          isPvActive = val;
                        });
                        _sendCommand("PV:${val ? 1 : 0}");
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fan Card (Full Width with integrated Speed Slider)
              FanControlCard(
                title: 'Fan (DC Motor)',
                subtitle: isFanOn
                    ? 'Running (${(fanSpeed / 255 * 100).toStringAsFixed(0)}%)'
                    : 'Stopped',
                icon: Icons.ac_unit,
                isOn: isFanOn,
                activeColor: Colors.purpleAccent,
                fanSpeed: fanSpeed,
                onChanged: (val) {
                  setState(() {
                    isFanOn = val;
                  });
                  _sendCommand("FAN:${val ? 1 : 0},${fanSpeed.toInt()}");
                },
                onSpeedChanged: (val) {
                  setState(() {
                    fanSpeed = val;
                  });
                  if (isFanOn) {
                    _sendCommand("FAN:1,${val.toInt()}");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Standard Device Card
class DeviceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOn;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const DeviceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isOn,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOn ? activeColor.withValues(alpha: 0.15) : const Color(0xFF1E2238),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOn ? activeColor : Colors.white10,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 26,
                color: isOn ? activeColor : Colors.grey,
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: isOn,
                  onChanged: onChanged,
                  activeColor: activeColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isOn ? activeColor : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Fan Control Card with Embedded Slider
class FanControlCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOn;
  final Color activeColor;
  final double fanSpeed;
  final ValueChanged<bool> onChanged;
  final ValueChanged<double> onSpeedChanged;

  const FanControlCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isOn,
    required this.activeColor,
    required this.fanSpeed,
    required this.onChanged,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isOn ? activeColor.withValues(alpha: 0.15) : const Color(0xFF1E2238),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOn ? activeColor : Colors.white10,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isOn ? activeColor : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isOn ? activeColor : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isOn,
                  onChanged: onChanged,
                  activeColor: activeColor,
                ),
              ),
            ],
          ),
          if (isOn) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Speed (PWM)',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${(fanSpeed / 255 * 100).toStringAsFixed(0)}% (${fanSpeed.toInt()} / 255)',
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Slider(
              value: fanSpeed,
              min: 0,
              max: 255,
              divisions: 10,
              activeColor: activeColor,
              inactiveColor: Colors.white10,
              onChanged: onSpeedChanged,
            ),
          ],
        ],
      ),
    );
  }
}