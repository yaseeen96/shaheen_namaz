import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shaheen_namaz/admin/widgets/certificates/single_certificate_card.dart';
import 'package:shaheen_namaz/common/widgets/loading_indicator.dart';
import 'package:shaheen_namaz/utils/config/logger.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';

class CertificateList extends ConsumerStatefulWidget {
  const CertificateList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CertificateListState();
}

class _CertificateListState extends ConsumerState<CertificateList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  int _selectedCluster = 0;

  Query _getQuery() {
    Query query = FirebaseFirestore.instance.collection('certificates');

    if (_searchText.isNotEmpty) {
      query = query.where('guardianNumber', isEqualTo: _searchText);
      logger.i("Query with search text: $_searchText");
    }

    if (_selectedCluster != 0) {
      query = query.where('masjid_details.clusterNumber',
          isEqualTo: _selectedCluster);
      logger.i("Query with cluster number: $_selectedCluster");
    }

    return query;
  }

  void _onSearch() {
    setState(() {
      _searchText = _searchController.text;
      logger.i("Search text: $_searchText");
    });
  }

  void _onChipSelected(int clusterNumber) {
    setState(() {
      _selectedCluster = clusterNumber;
      logger.i("Selected cluster: $_selectedCluster");
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        surfaceTintColor: Constants.bgColor,
        title: const Text("Certificates"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by Guardian Number',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _onSearch,
                    ),
                  ),
                  onChanged: (value) {
                    _onSearch();
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(12, (index) {
                    final clusterNumber = index + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text('Cluster $clusterNumber'),
                        selected: _selectedCluster == clusterNumber,
                        onSelected: (selected) {
                          _onChipSelected(selected ? clusterNumber : 0);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: _getQuery().get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomLoadingIndicator();
          } else if (snapshot.hasError) {
            logger.e("Error: ${snapshot.error}");
            return const Center(child: Text('An error occurred'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found'));
          } else {
            return FirestorePagination(
              key: ValueKey('$_searchText-$_selectedCluster'),
              padding: const EdgeInsets.all(20),
              viewType: ViewType.grid,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              isLive: true,
              query: _getQuery(),
              itemBuilder: (context, docs, index) {
                try {
                  final data = docs.data() as Map<String, dynamic>;
                  logger.i("Item $index: $data");
                  return SingleCertificateCard(
                    certificateUrl: data["certificate"],
                    name: data["name"],
                    guardianNumber: data["guardianNumber"],
                    clusterNumber:
                        data["masjid_details"]["clusterNumber"].toString(),
                  );
                } catch (e, stackTrace) {
                  logger.e("Error in itemBuilder: $e\n$stackTrace");
                  return const Center(
                      child: Text('An error occurred with this item'));
                }
              },
              onEmpty: const Center(child: Text('No students found')),
            );
          }
        },
      ),
    );
  }
}
