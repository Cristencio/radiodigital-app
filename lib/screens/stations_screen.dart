import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/radio_provider.dart';
import '../data/stations_data.dart';
import '../widgets/station_card.dart';
import 'main_screen.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = "todas";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<RadioProvider>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  String _getCategoryDisplay(String category) {
    final map = {
      "todas": "Todas",
      "Notícias": "Notícias",
      "Música": "Música",
      "Comunitária": "Comunitária",
      "Religiosa": "Religiosa",
      "Gospel": "Gospel",
      "Desporto": "Desporto",
      "Rock": "Rock",
      "Pop": "Pop",
      "Educacional": "Educacional",
      "Variedades": "Variedades",
      "Generalista": "Generalista",
      "World": "World",
      "Easy-Listening": "Easy",
      "R&B": "R&B",
      "Juvenil": "Juvenil",
      "Entrevistas": "Entrevistas",
      "Rap/Hip-Hop": "Rap/Hip-Hop",
    };
    return map[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RadioProvider>(context);
    final isDark = provider.isDarkMode;
    final filteredStations = provider.filteredStations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isDark),
              const SizedBox(height: 12),
              _buildCategoryFilter(isDark, provider),
            ],
          ),
        ),
        Expanded(
          child: filteredStations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.radio,
                        size: 64,
                        color: isDark
                            ? const Color(0xFF2C2C32)
                            : const Color(0xFFD8C1C0),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Nenhuma estação encontrada",
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF5F5E5E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tente outros filtros ou busca",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF71717A)
                              : const Color(0xFFA8A29E),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredStations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StationCard(
                        station: filteredStations[index],
                        onPlay: () async {
                          await provider
                              .setCurrentStation(filteredStations[index]);
                          await provider.playCurrentStation();
                          if (context.mounted) {
                            final mainScreen = context
                                .findAncestorStateOfType<MainScreenState>();
                            mainScreen?.navigateToPlayer();
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C32) : const Color(0xFFD8C1C0),
          width: 0.8,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Pesquisar...",
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF71717A) : const Color(0xFFA8A29E),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: isDark ? const Color(0xFF71717A) : const Color(0xFFA8A29E),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        ),
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white : const Color(0xFF1B1C1C),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark, RadioProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: StationsData.getCategories().map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _getCategoryDisplay(category),
                style: const TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  provider.setSelectedCategory(category);
                });
              },
              backgroundColor: isDark ? const Color(0xFF1F1F24) : Colors.white,
              selectedColor: const Color(0xFFF8A3A3).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF8E4B4C),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF8E4B4C)
                    : (isDark
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF5F5E5E)),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFF8A3A3)
                      : (isDark
                          ? const Color(0xFF2C2C32)
                          : const Color(0xFFD8C1C0)),
                  width: 0.8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
