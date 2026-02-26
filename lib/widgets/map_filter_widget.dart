import 'package:flutter/material.dart';
import '../models/pin.dart';
import '../utils/ui_utils.dart';

class MapFilterWidget extends StatefulWidget {
  final Set<PostType> selectedTypes;
  final Set<PostCategory> selectedCategories;
  final DateTimeRange? dateRange;
  final Function(Set<PostType>) onTypeChanged;
  final Function(Set<PostCategory>) onCategoryChanged;
  final Function(DateTimeRange?) onDateRangeChanged;

  const MapFilterWidget({
    super.key,
    required this.selectedTypes,
    required this.selectedCategories,
    required this.dateRange,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
  });

  @override
  State<MapFilterWidget> createState() => _MapFilterWidgetState();
}

class _MapFilterWidgetState extends State<MapFilterWidget> {
  late Set<PostType> _selectedTypes;
  late Set<PostCategory> _selectedCategories;
  late DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.selectedTypes);
    _selectedCategories = Set.from(widget.selectedCategories);
    _dateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'フィルター',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('リセット'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTypeFilters(),
          const SizedBox(height: 24),
          _buildCategoryFilters(),
          const SizedBox(height: 24),
          _buildDateRangeFilter(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('適用'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投稿タイプ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PostType.values.map((type) {
            final isSelected = _selectedTypes.contains(type);
            final label = type == PostType.visited ? '行った' : '行きたい';
            final icon = type == PostType.visited
                ? Icons.check_circle
                : Icons.favorite;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16),
                  const SizedBox(width: 4),
                  Text(label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTypes.add(type);
                  } else {
                    _selectedTypes.remove(type);
                  }
                });
              },
              selectedColor: UIUtils.primaryColor.withOpacity(0.3),
              checkmarkColor: UIUtils.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PostCategory.values.map((category) {
            final isSelected = _selectedCategories.contains(category);
            final categoryKey = category.toString().split('.').last;
            final color = UIUtils.getCategoryColor(categoryKey);
            final label = UIUtils.getCategoryLabel(categoryKey);

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              selectedColor: color.withOpacity(0.3),
              checkmarkColor: color,
              side: BorderSide(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '期間',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: UIUtils.primaryColor),
          title: Text(_dateRange != null
              ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
              : '期間を選択'),
          trailing: _dateRange != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _dateRange = null;
                    });
                  },
                )
              : const Icon(Icons.edit),
          onTap: _selectDateRange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: UIUtils.primaryColor.withOpacity(0.3)),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedTypes = Set.from(PostType.values);
      _selectedCategories = Set.from(PostCategory.values);
      _dateRange = null;
    });
  }

  void _applyFilters() {
    widget.onTypeChanged(_selectedTypes);
    widget.onCategoryChanged(_selectedCategories);
    widget.onDateRangeChanged(_dateRange);
    Navigator.pop(context);
  }
}
