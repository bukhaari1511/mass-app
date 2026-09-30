import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/product_repository.dart';
import '../../../core/models/product_model.dart';
import '../widgets/product_image_widget.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({
    super.key,
    this.product,
  });

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductRepository _productRepo = ProductRepository();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _brandController;
  late TextEditingController _vehicleController;
  late TextEditingController _modelController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _initialStockController;
  late TextEditingController _minimumStockController;

  String _selectedCategory = 'Cars';
  String? _selectedImagePath;
  bool _isSaving = false;

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _vehicleController = TextEditingController(text: p?.vehicle ?? '');
    _modelController = TextEditingController(text: p?.model ?? '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toString() : '');
    _sellingPriceController = TextEditingController(text: p != null ? p.sellingPrice.toString() : '');
    _initialStockController = TextEditingController(text: p != null ? p.stockQuantity.toString() : '0');
    _minimumStockController = TextEditingController(text: p != null ? p.minimumStock.toString() : '2');

    // Handle existing legacy categories safely
    if (p?.category != null) {
      if (p!.category!.toLowerCase().contains('bajaj')) {
        _selectedCategory = 'Bajaj';
      } else {
        _selectedCategory = 'Cars';
      }
    } else {
      _selectedCategory = 'Cars';
    }

    _selectedImagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _vehicleController.dispose();
    _modelController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _initialStockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImagePath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo with Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_selectedImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final skuText = _skuController.text.trim();

    setState(() {
      _isSaving = true;
    });

    // Validate SKU uniqueness
    final skuExists = await _productRepo.isSkuExists(
      skuText,
      excludeId: widget.product?.id,
    );

    if (skuExists) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This SKU already exists. Please use a unique SKU.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final double costPrice = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final double sellingPrice = double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
    final int initialStock = int.tryParse(_initialStockController.text.trim()) ?? 0;
    final int minimumStock = int.tryParse(_minimumStockController.text.trim()) ?? 0;

    final newProduct = ProductModel(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      sku: skuText,
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      category: _selectedCategory, // Strictly 'Cars' or 'Bajaj'
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      vehicle: _vehicleController.text.trim().isEmpty ? null : _vehicleController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      imagePath: _selectedImagePath,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      stockQuantity: isEditMode ? widget.product!.stockQuantity : initialStock,
      minimumStock: minimumStock,
      isActive: true,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (isEditMode) {
        await _productRepo.updateProduct(newProduct);
      } else {
        await _productRepo.insertProduct(newProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Product "${newProduct.name}" updated successfully!'
                  : 'Product "${newProduct.name}" added successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to signal list refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Add New Spare Part'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Picker Card
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      ProductImageWidget(
                        imagePath: _selectedImagePath,
                        width: 130,
                        height: 130,
                        borderRadius: 16,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _selectedImagePath == null ? 'Tap to add product photo' : 'Tap to change photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section: Basic Info
              _buildSectionTitle('Basic Information', isDark),
              const SizedBox(height: 12),

              // Product Name (Required)
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g. SAAMBO MATOOR WEYN PROBOX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Product Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SKU / Product Number (Required)
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU / Product Number *',
                  hintText: 'e.g. 12305',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'SKU is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selection (Strictly Cars or Bajaj)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'Cars',
                        label: Text('Cars'),
                        icon: Icon(Icons.directions_car),
                      ),
                      ButtonSegment<String>(
                        value: 'Bajaj',
                        label: Text('Bajaj'),
                        icon: Icon(Icons.two_wheeler),
                      ),
                    ],
                    selected: {_selectedCategory},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedCategory = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Pricing & Stock
              _buildSectionTitle('Pricing & Inventory', isDark),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Cost Price (Required)
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (\$) *',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Cost price required';
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal < 0) {
                          return 'Enter valid price >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Selling Price (Required)
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (\$) *',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Selling price required';
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal < 0) {
                          return 'Enter valid price >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  // Initial Stock (Only shown when adding new product)
                  if (!isEditMode)
                    Expanded(
                      child: TextFormField(
                        controller: _initialStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Initial Stock',
                          hintText: '0',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty) {
                            final intVal = int.tryParse(val.trim());
                            if (intVal == null || intVal < 0) {
                              return 'Must be >= 0';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  if (!isEditMode) const SizedBox(width: 12),

                  // Minimum Stock Limit
                  Expanded(
                    child: TextFormField(
                      controller: _minimumStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Stock Warning',
                        hintText: '2',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          final intVal = int.tryParse(val.trim());
                          if (intVal == null || intVal < 0) {
                            return 'Must be >= 0';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Vehicle Compatibility (Optional)
              _buildSectionTitle('Vehicle Specs (Optional)', isDark),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        hintText: 'e.g. Toyota, Bajaj',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _vehicleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        hintText: 'e.g. Probox, RE 4S',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model / Year',
                        hintText: 'e.g. 2018 / 4 Stroke',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                        hintText: 'Scan or type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(isEditMode ? Icons.check_circle_outline : Icons.save_outlined),
                  label: Text(
                    _isSaving
                        ? 'Saving Product...'
                        : (isEditMode ? 'Update Product' : 'Save Product'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }
}
