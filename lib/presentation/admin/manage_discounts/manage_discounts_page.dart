import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cua_hang_thoi_trang/domain/models/discount_model.dart';
import 'package:cua_hang_thoi_trang/presentation/discount/bloc/discount_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ManageDiscountsPage extends StatelessWidget {
  const ManageDiscountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý mã giảm giá'),
      ),
      body: BlocBuilder<DiscountBloc, DiscountState>(
        builder: (context, state) {
          if (state is DiscountLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiscountLoaded) {
            return ListView.builder(
              itemCount: state.discounts.length,
              itemBuilder: (context, index) {
                final discount = state.discounts[index];
                return ListTile(
                  title: Text(discount.code),
                  subtitle: Text(
                      '${discount.percentage}% - Hết hạn: ${DateFormat('dd/MM/yyyy').format(discount.expiryDate.toDate())}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showAddEditDiscountDialog(context, discount: discount);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<DiscountBloc>().add(DeleteDiscount(discount.id));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
          if (state is DiscountError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Không có mã giảm giá nào.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDiscountDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDiscountDialog(BuildContext context, {Discount? discount}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddEditDiscountDialog(
          discount: discount,
          discountBloc: context.read<DiscountBloc>(),
        );
      },
    );
  }
}

class AddEditDiscountDialog extends StatefulWidget {
  final Discount? discount;
  final DiscountBloc discountBloc;

  const AddEditDiscountDialog({super.key, this.discount, required this.discountBloc});

  @override
  _AddEditDiscountDialogState createState() => _AddEditDiscountDialogState();
}

class _AddEditDiscountDialogState extends State<AddEditDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _code;
  late double _percentage;
  late DateTime _expiryDate;

  @override
  void initState() {
    super.initState();
    _code = widget.discount?.code ?? '';
    _percentage = widget.discount?.percentage ?? 0.0;
    _expiryDate = widget.discount?.expiryDate.toDate() ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.discount == null ? 'Thêm mã giảm giá' : 'Sửa mã giảm giá'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _code,
              decoration: const InputDecoration(labelText: 'Mã giảm giá'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã giảm giá';
                }
                return null;
              },
              onSaved: (value) => _code = value!,
            ),
            TextFormField(
              initialValue: _percentage.toString(),
              decoration: const InputDecoration(labelText: 'Phần trăm giảm'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập phần trăm giảm';
                }
                if (double.tryParse(value) == null) {
                  return 'Vui lòng nhập một số hợp lệ';
                }
                return null;
              },
              onSaved: (value) => _percentage = double.parse(value!),
            ),
            ListTile(
              title: Text('Ngày hết hạn: ${DateFormat('dd/MM/yyyy').format(_expiryDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _expiryDate) {
                  setState(() {
                    _expiryDate = pickedDate;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newDiscount = Discount(
                id: widget.discount?.id ?? '',
                code: _code,
                percentage: _percentage,
                expiryDate: Timestamp.fromDate(_expiryDate),
              );
              if (widget.discount == null) {
                widget.discountBloc.add(AddDiscount(newDiscount));
              } else {
                widget.discountBloc.add(UpdateDiscount(newDiscount));
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
