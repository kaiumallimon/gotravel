/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditouch/common/repository/bkash_repository.dart';
import 'package:meditouch/common/widgets/custom_loading_animation.dart';
import 'package:meditouch/features/dashboard/features/cart/models/cart_model.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../order/data/models/order_model.dart';
import '../../logics/cart_bloc.dart';
import '../../logics/cart_event.dart';
import '../../logics/cart_state.dart';
import 'parts/checkout_appbar.dart';
import 'parts/checkout_body.dart';

class CartCheckoutScreen extends StatelessWidget {
  const CartCheckoutScreen(
      {super.key, required this.cartItems, required this.selectedItems});

  final List<CartModel> cartItems;
  final List<String> selectedItems;

  @override
  Widget build(BuildContext context) {
    // get theme
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surfaceContainer,
      // appbar
      appBar: checkoutAppBar(theme),

      // body
      body: SafeArea(
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            // listen for checkout success and errors
            if (state is CartCheckoutSuccess) {
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  onConfirmBtnTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    context.read<CartBloc>().add(LoadCart());
                  },
                  text:
                      'Your order has been placed successfully, go to orders to track your order');
            }

            if (state is CartCheckoutError) {
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: 'Error',
                  onConfirmBtnTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    context.read<CartBloc>().add(LoadCart());
                  },
                  text: state.message);
            }
          },
          builder: (context, state) {
            if (state is CartCheckoutLoading) {
              return CustomLoadingAnimation(size: 30, color: theme.primary);
            }

            // if (state is CartCheckoutSuccess) {
            //   return checkoutSuccess(theme, context);
            // }

            if (state is CartPaymentWebview) {
              return checkoutWebView(
                  theme, context, state, cartItems, selectedItems);
            }

            // if (state is CartCheckoutError) {
            //   return Center(
            //     child: Text(
            //       state.message,
            //       style: TextStyle(color: theme.error),
            //     ),
            //   );
            // }

            return checkoutBody(context, theme, cartItems, selectedItems);
          },
        ),
      ),
    );
  }
}

Widget checkoutWebView(
    ColorScheme theme,
    BuildContext context,
    CartPaymentWebview state,
    List<CartModel> cartItems,
    List<String> selectedItems) {
  return WebViewWidget(
    controller: WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (url.contains('success')) {
              print('Executing payment, please wait!');

              try {
                final response = await BkashRepository().executePaymentresponse(
                  idToken: state.tokenId,
                  paymentID: state.paymentId,
                );

                if (response.statusMessage == 'Successful') {
                  BlocProvider.of<CartBloc>(context).add(PaymentExecuted(
                      cartIds: selectedItems,
                      paymentId: state.paymentId,
                      transactionId: response.trxID,
                      amount: response.amount,
                      currency: response.currency,
                      invoiceNumber: response.merchantInvoiceNumber,
                      order: OrderModel(
                          medicines: state.medicines,
                          uid: state.uid,
                          orderStatus: 'Processing',
                          orderDate: DateTime.now(),
                          deliveryAddress: state.deliveryAddress,
                          userPhoneNumber: state.userPhone,
                          userFullName: state.userFullName,
                          paymentMethod: "bKash",
                          paymentStatus: "Paid",
                          totalPrice: state.totalAmount,
                          orderId: "")));
                } else {
                  BlocProvider.of<CartBloc>(context)
                      .add(CartCheckoutGotError(response.statusMessage));
                }
              } catch (e) {
                BlocProvider.of<CartBloc>(context)
                    .add(CartCheckoutGotError(e.toString()));
              }
            } else if (url.contains('failure')) {
              BlocProvider.of<CartBloc>(context)
                  .add(CartCheckoutGotError('Payment failed'));
            } else if (url.contains('cancelled')) {
              BlocProvider.of<CartBloc>(context)
                  .add(CartCheckoutGotError('Payment cancelled'));
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(state.paymentUrl)),
  );
}
 */