import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.height = 48,
    this.width = 200,
    required this.text,
    this.bgColor,
    this.fgColor,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.loadingText = 'Please wait',
  });

  final double height;
  final double width;
  final String text;
  final Color? bgColor;
  final Color? fgColor;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final String loadingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: fgColor ?? theme.colorScheme.primary,
                side: BorderSide(
                  color: bgColor ?? theme.colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor ?? theme.colorScheme.primary,
                foregroundColor: fgColor ?? theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Center(
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            loadingText,
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
    );
  }
}
