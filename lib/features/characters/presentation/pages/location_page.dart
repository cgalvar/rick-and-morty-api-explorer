import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/app_icon_set.dart';
import '../../domain/entities.dart';
import '../../domain/use_cases.dart';
import '../location_cubit.dart';
import '../widgets.dart';

@RoutePage()
class LocationDetailPage extends StatelessWidget {
  const LocationDetailPage({super.key, @PathParam('id') required this.id});

  final int id;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => LocationCubit(context.read<GetLocation>())..load(id),
    child: Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LocationCubit, LocationState>(
          builder: (_, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.location?.name ?? 'Ubicación'),
              const Text(
                'ARCHIVO DE UBICACIÓN',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, state) {
          if (state.loading) {
            return Center(
              child: Semantics(
                label: 'Cargando ubicación',
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state.error != null) {
            return AsyncStateView(
              message: state.error!,
              onRetry: context.read<LocationCubit>().retry,
            );
          }
          return _LocationProfile(location: state.location!);
        },
      ),
    ),
  );
}

class _LocationProfile extends StatelessWidget {
  const _LocationProfile({required this.location});

  final LocationDetail location;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final facts = [
      _LocationFact(
        label: 'Tipo',
        value: _fallback(location.type),
        semanticValue: _fallback(location.type),
      ),
      _LocationFact(
        label: 'Dimensión',
        value: _fallback(location.dimension),
        semanticValue: _fallback(location.dimension),
      ),
      _LocationFact(
        label: 'Residentes',
        value: '${location.residentCount}',
        supportingText: 'registrados',
        semanticValue: '${location.residentCount} registrados',
        prominent: true,
      ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: const Alignment(0, .42),
          colors: [
            colors.secondaryContainer.withValues(alpha: .36),
            colors.surface,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final padding = constraints.maxWidth >= 1024
              ? 32.0
              : wide
              ? 24.0
              : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Semantics(
                  container: true,
                  label: 'Perfil de ubicación: ${location.name}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer.withValues(
                            alpha: .72,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: .8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              AppIcons.resolve(AppIcon.location),
                              color: colors.onSecondaryContainer,
                              size: 38,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'UBICACIÓN #${location.id.toString().padLeft(3, '0')}',
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.onSecondaryContainer,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              location.name,
                              style: textTheme.headlineMedium?.copyWith(
                                color: colors.onSecondaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Chip(
                              label: Text(_fallback(location.type)),
                              backgroundColor: colors.surface.withValues(
                                alpha: .72,
                              ),
                              side: BorderSide(color: colors.outlineVariant),
                              labelStyle: textTheme.labelLarge?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        container: true,
                        label: 'Datos de la ubicación',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final factWidth = wide
                                ? (constraints.maxWidth - 12) / 2
                                : constraints.maxWidth;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final fact in facts)
                                  SizedBox(
                                    width: factWidth,
                                    child: _LocationFactCard(fact: fact),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _fallback(String value) =>
      value.trim().isEmpty ? 'No especificado' : value;
}

class _LocationFact {
  const _LocationFact({
    required this.label,
    required this.value,
    required this.semanticValue,
    this.supportingText,
    this.prominent = false,
  });

  final String label;
  final String value;
  final String semanticValue;
  final String? supportingText;
  final bool prominent;
}

class _LocationFactCard extends StatelessWidget {
  const _LocationFactCard({required this.fact});

  final _LocationFact fact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '${fact.label}: ${fact.semanticValue}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: fact.prominent
              ? colors.primaryContainer.withValues(alpha: .72)
              : colors.surfaceContainerHighest.withValues(alpha: .64),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fact.label.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: fact.prominent
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fact.value,
              style:
                  (fact.prominent
                          ? textTheme.headlineMedium
                          : textTheme.titleLarge)
                      ?.copyWith(
                        color: fact.prominent
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (fact.supportingText case final supportingText?) ...[
              const SizedBox(height: 2),
              Text(
                supportingText,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
