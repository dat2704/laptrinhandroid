import 'package:cua_hang_thoi_trang/presentation/discount/bloc/discount_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã giảm giá'),
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
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(discount.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Giảm ${discount.percentage}% - Hết hạn: ${DateFormat('dd/MM/yyyy').format(discount.expiryDate.toDate())}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement logic to apply discount
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã sao chép mã: ${discount.code}')),
                        );
                      },
                      child: const Text('Lấy mã'),
                    ),
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
    );
  }
}
