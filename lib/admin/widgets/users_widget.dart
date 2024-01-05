import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shaheen_namaz/admin/providers/get_users_provider.dart';

class UsersWidget extends ConsumerWidget {
  const UsersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(getUsersProvider);
    return users.when(
      data: (user) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Users",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text("Add New User"),
                ),
              ],
            ),
            const Gap(6),
            ListView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemCount: user.users!.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: ListTile(
                      title: Text(user.users![index].email!),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      tileColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  );
                }),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stk) => Center(
        child: Text("An Error Occurred. Error: $err"),
      ),
    );
  }
}
