import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> historyItems = [];
  bool loading = true;

  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    loadHistory();
    setupRealtime();
  }

  @override
  void dispose() {
    channel?.unsubscribe();
    super.dispose();
  }

  Future<void> loadHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('scan_history')
        .select()
        .eq("profile_id", userId)
        .order("created_at", ascending: false);

    setState(() {
      historyItems = response;
      loading = false;
    });
  }

 void setupRealtime() {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return;

  channel = supabase.channel('scan_history_changes')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,   
      schema: 'public',
      table: 'scan_history',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,  
        column: 'profile_id',
        value: userId,
      ),
      callback: (payload) {
        print("Realtime event received: $payload");
        loadHistory(); 
      },
    )
    .subscribe();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
 backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : historyItems.isEmpty
              ? const Center(child: Text("No history found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: historyItems.length,
                  itemBuilder: (context, index) {
                    final item = historyItems[index];

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item["image"] != null
                              ? Image.network(
                                  item["image"],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.broken_image, size: 40),
                        ),

                        title: Text(
                          item["name"] ?? "Unknown Product",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Brand: ${item["brand"] ?? "Unknown"}"),
                            const SizedBox(height: 4),
                            Text(
                              "Added: ${_formatDate(item["created_at"])}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return "";
    try {
      final dt = DateTime.parse(date);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
    } catch (e) {
      return date;
    }
  }
}
