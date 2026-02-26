import 'package:flutter/material.dart';
import '../models/pin.dart';
import '../utils/ui_utils.dart';

class MapFilterWidget extends StatefulWidget {
  final Set<PinCategory> selectedCategories;
  final DateTimeRange? dateRange;
  final Function(Set<PinCategory>) onCategoryChanged;
  final Function(DateTimeRange?) onDateRangeChanged;

  const MapFilterWidget({
    super.key,
    required this.selectedCategories,
    this.dateRange,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
  });

  @override
  State<MapFilterWidget> createState() => _MapFilterWidgetState();
}

class _MapFilterWidgetState extends State<MapFilterWidget> {
  late Set<PinCategory> _selectedCategories;
  late DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.selectedCategories);
    _dateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UIUtils.textColor,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('リセット'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'カテゴリ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UIUtils.textColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategoryFilters(),
          const SizedBox(height: 16),
          const Text(
            '期間',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: UIUtils.textColor,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildCategoryFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PinCategory.values.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(_getCategoryLabel(category)),
          selected: isSelected,
          selectedColor: _getCategoryColor(category).withOpacity(0.3),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeFilter() {
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(Icons.calendar_today),
      label: Text(
        _dateRange != null
            ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
            : '期間を選択',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  String _getCategoryLabel(PinCategory category) {
    switch (category) {
      case PinCategory.visited:
        return '行った場所';
      case PinCategory.wantToGo:
        return '行きたい場所';
      case PinCategory.diary:
        return '日記';
    }
  }

  Color _getCategoryColor(PinCategory category) {
    switch (category) {
      case PinCategory.visited:
        return UIUtils.visitedColor;
      case PinCategory.wantToGo:
        return UIUtils.wantToGoColor;
      case PinCategory.diary:
        return UIUtils.diaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: UIUtils.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories = Set.from(PinCategory.values);
      _dateRange = null;
    });
  }

  void _applyFilters() {
    widget.onCategoryChanged(_selectedCategories);
    widget.onDateRangeChanged(_dateRange);
    Navigator.pop(context);
  }
}
