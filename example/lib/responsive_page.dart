import 'package:app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

class ResponsivePage extends StatefulWidget {
  const ResponsivePage({super.key});

  @override
  State<ResponsivePage> createState() => _ResponsivePageState();
}

class _ResponsivePageState extends State<ResponsivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey background
      appBar: AppBar(
        title: Text('Responsive Logic Test', style: context.large),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: const _ResponsiveBody(),
    );
  }
}

class _ResponsiveBody extends StatelessWidget {
  const _ResponsiveBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w), // Scaled padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsCard(context),
          20.vGap, // Scaled gap
          _buildScaleVisualizer(context),
          20.vGap,
          _buildTypographySection(context),
          20.vGap,
          _buildAdaptiveLayoutExample(context),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context) {
    final sizes = context.appSizes;
    final metrics = [
      _MetricItem(
        'Screen',
        '${sizes.screenWidth.toInt()} x ${sizes.screenHeight.toInt()}',
        Icons.aspect_ratio_rounded,
        Colors.blue,
      ),
      _MetricItem(
        'Device',
        sizes.deviceType.name.toUpperCase(),
        Icons.devices_rounded,
        Colors.purple,
      ),
      _MetricItem(
        'Scale W',
        '${sizes.scaleW.toStringAsFixed(3)}x',
        Icons.width_full_rounded,
        Colors.orange,
      ),
      _MetricItem(
        'Scale H',
        '${sizes.scaleH.toStringAsFixed(3)}x',
        Icons.height_rounded,
        Colors.teal,
      ),
      _MetricItem(
        'Scale Txt',
        '${sizes.scaleText.toStringAsFixed(3)}x',
        Icons.text_fields_rounded,
        Colors.pink,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard Metrics', style: context.title),
        16.vGap,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2.value(context, tablet: 3, desktop: 4),
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.4,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final item = metrics[index];
            return Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: item.color.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 20.r),
                  ),
                  const Spacer(),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.vGap,
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScaleVisualizer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scaling Visualizer',
          style: context.title,
        ),
        10.vGap,
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              _buildBar(context, 50, Colors.blueAccent),
              10.vGap,
              _buildBar(context, 100, Colors.purpleAccent),
              10.vGap,
              _buildBar(context, 200, Colors.orangeAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(BuildContext context, double designWidth, Color color) {
    final sizes = context.appSizes;
    final actualWidth = designWidth.w;
    return Row(
      children: [
        Container(
          width: actualWidth,
          height: 30.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
          alignment: Alignment.center,
          child: Text(
            '${designWidth.toInt()}',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold),
          ),
        ),
        10.hGap,
        Expanded(
          child: Text(
            '$designWidth * ${sizes.scaleW.toStringAsFixed(2)} = ${actualWidth.toStringAsFixed(1)}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTypographySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography Standard',
          style: context.title,
        ),
        10.vGap,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Extra Large Text (26)', style: context.extraLarge),
              Text('Large Text (20)', style: context.large),
              Text('Medium Text (16)', style: context.medium),
              Text('Small Text (12)', style: context.small),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveLayoutExample(BuildContext context) {
    // Uses the .value() extension for responsive values
    final columns = 2.value(context, tablet: 3, desktop: 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adaptive Layout (Grid)',
          style: context.title,
        ),
        Text(
          'Columns: $columns (Resize window to test)',
          style: context.subtitle.copyWith(color: Colors.grey),
        ),
        10.vGap,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 1.5,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1 + (index * 0.1)),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.teal),
              ),
              alignment: Alignment.center,
              child: Text(
                'Item ${index + 1}',
                style: context.medium.copyWith(color: Colors.teal[900]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem(this.label, this.value, this.icon, this.color);
}
