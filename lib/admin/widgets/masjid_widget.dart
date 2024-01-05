import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/providers/get_masjids_provider.dart';

class MasjidWidget extends ConsumerWidget {
  const MasjidWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masjids = ref.watch(getMasjidProvider);
    return masjids.when(
      data: (data) {
        final masjidList = data.docs;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Masjids",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add Masjid"),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: masjidList.length,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      masjidList[index].data()["name"],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                    tileColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      error: (err, stk) {
        return Center(
          child: Text("An Error Occurred. $err"),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
