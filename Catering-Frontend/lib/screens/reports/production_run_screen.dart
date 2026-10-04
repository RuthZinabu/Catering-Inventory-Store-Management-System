import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class ProductionRunScreen extends StatefulWidget {
  const ProductionRunScreen({super.key});

  @override
  State<ProductionRunScreen> createState() => _ProductionRunScreenState();
}

class _ProductionRunScreenState extends State<ProductionRunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _servings = TextEditingController(text: '1');
  final _notes = TextEditingController();
  final _date = TextEditingController(text: _today());
  List<Map<String, dynamic>> _recipes = [];
  String? _recipeId;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _servings.dispose();
    _notes.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final path = Uri(
        path: '/recipes',
        queryParameters: const {'status': 'Active', 'per_page': '100'},
      ).toString();
      final response = await ApiClient.instance.get(path);
      final data = Map<String, dynamic>.from(response['data'] as Map);
      final recipes = (data['items'] as List? ?? const [])
          .map((recipe) => Map<String, dynamic>.from(recipe as Map))
          .where((recipe) => recipe['status'] == 'Active')
          .toList();
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _recipeId = recipes.isEmpty ? null : recipes.first['id'] as String;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) _date.text = _dateString(date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final storeId = ApiClient.instance.storeId;
    if (storeId == null) {
      setState(() => _error = 'Select a store before recording production.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient.instance.post('/production-runs', {
        'store_id': storeId,
        'recipe_id': _recipeId,
        'production_date': _date.text,
        'produced_servings': double.parse(_servings.text),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Kitchen Production')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Production quantities are compared with ingredient quantities in the selected recipe. Recipe details are saved with the production record.',
                  ),
                  const SizedBox(height: 18),
                  if (_recipes.isEmpty)
                    Text(_error ?? 'No active recipes are available.')
                  else
                    DropdownButtonFormField<String>(
                      value: _recipeId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Recipe / menu item'),
                      items: _recipes
                          .map((recipe) => DropdownMenuItem(
                                value: recipe['id'] as String,
                                child: Text(recipe['name'] as String? ?? 'Recipe', overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _recipeId = value),
                      validator: (value) => value == null ? 'Select a recipe.' : null,
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _servings,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Servings produced',
                      helperText: 'Ingredient usage is scaled from the recipe yield.',
                    ),
                    validator: (value) {
                      final quantity = double.tryParse(value ?? '');
                      return quantity == null || quantity <= 0 ? 'Enter a quantity above zero.' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _date,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Production date',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving || _recipes.isEmpty ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Production'),
                  ),
                ],
              ),
            ),
    );
  }
}

String _today() => _dateString(DateTime.now());

String _dateString(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';