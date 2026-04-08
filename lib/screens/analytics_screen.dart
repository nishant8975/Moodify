import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: context.colors.background.withOpacity(0.8)),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mood Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: context.colors.surfaceContainerHighest,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=150&q=80'),
              radius: 20,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Time selector
              Center(
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTab(context, 'Week', true),
                      _buildTab(context, 'Month', false),
                      _buildTab(context, 'Year', false),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              
              // Mood Fluctuations Chart
              GlassContainer(
                padding: EdgeInsets.all(32),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mood Fluctuations', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Real-time emotional tracking over 7 days', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.secondaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.secondaryFixedDim.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: context.colors.secondaryFixedDim, shape: BoxShape.circle)),
                              SizedBox(width: 8),
                              Text('84% Stability', style: TextStyle(color: context.colors.secondaryFixed, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 40),
                    
                    // Faux Chart
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => Divider(color: context.colors.onSurface.withOpacity(0.1))),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildBar(context, 'MON', 0.6),
                              _buildBar(context, 'TUE', 0.45),
                              _buildBar(context, 'WED', 0.85, 0.2, true),
                              _buildBar(context, 'THU', 0.7),
                              _buildBar(context, 'FRI', 0.55),
                              _buildBar(context, 'SAT', 0.9),
                              _buildBar(context, 'SUN', 0.8),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Sleep patterns & Activity
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: EdgeInsets.all(24),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(color: context.colors.tertiaryContainer.withOpacity(0.2), shape: BoxShape.circle),
                                child: Icon(Icons.bedtime, color: context.colors.tertiary),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Sleep Quality', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('7h 42m', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                              Text('+12%', style: TextStyle(color: context.colors.secondaryFixed, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(color: context.colors.surfaceContainer, borderRadius: BorderRadius.circular(4)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.78,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [context.colors.tertiary, context.colors.primaryDim]),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: GlassContainer(
                      padding: EdgeInsets.all(24),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bolt, color: context.colors.secondaryFixed),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Activity Level', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Center(
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(value: 0.75, color: context.colors.secondaryFixed, backgroundColor: context.colors.surfaceContainerHighest, strokeWidth: 8),
                                  Center(child: Text('75%', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 24),
              
              // Insights
              GlassContainer(
                padding: EdgeInsets.all(32),
                borderRadius: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Key Insights', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Icon(Icons.auto_awesome, color: context.colors.primaryFixedDim),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildInsightCard(context, 'Morning Boost', 'Elevated Mood during Mornings is consistent with your increased 8 AM meditation sessions.', Icons.wb_sunny, context.colors.primaryDim),
                    SizedBox(height: 16),
                    _buildInsightCard(context, 'Improved Sleep Quality', 'Consistent bedtime routines have improved your REM sleep by 15% this month.', Icons.nights_stay, context.colors.secondaryFixed),
                    SizedBox(height: 16),
                    _buildInsightCard(context, 'Stress Resilience', 'Activity spikes no longer trigger anxiety drops. Your resilience score is at an all-time high.', Icons.psychology, context.colors.tertiary),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? context.colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(title, style: TextStyle(color: isActive ? context.colors.onPrimaryContainer : context.colors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildBar(BuildContext context, String day, double heightFactor, [double? innerDotPos, bool star = false]) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FractionallySizedBox(
                    heightFactor: heightFactor,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [context.colors.primary.withOpacity(0.1), context.colors.primary.withOpacity(0.4)],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          if (!star)
                            Positioned(
                              top: -6,
                              child: CircleAvatar(radius: 6, backgroundColor: context.colors.primary, child: CircleAvatar(radius: 4, backgroundColor: context.colors.onSurface)),
                            )
                          else
                            Positioned(
                              top: -8,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: context.colors.secondaryFixed,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: context.colors.secondaryFixed.withOpacity(0.8), blurRadius: 15)],
                                ),
                                child: Icon(Icons.star, color: context.colors.inverseSurface, size: 10),
                              ),
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(day, style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String body, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
              SizedBox(width: 16),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          SizedBox(height: 12),
          Text(body, style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
