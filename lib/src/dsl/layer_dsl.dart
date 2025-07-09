import '../rules/layer_rule.dart';
import '../utils/layer_validation_type.dart';

class LayerRuleBuilder {
  final List<String> _layers;
  LayerValidationType _validationType = LayerValidationType.both;
  bool _allowMissingLayers = true;

  LayerRuleBuilder(this._layers);

  LayerRuleBuilder onlyStructure() {
    _validationType = LayerValidationType.structure;
    return this;
  }

  LayerRuleBuilder onlyDependencies() {
    _validationType = LayerValidationType.dependencies;
    return this;
  }

  LayerRuleBuilder requireAllLayers() {
    _allowMissingLayers = false;
    return this;
  }

  LayerRuleBuilder allowMissingLayers() {
    _allowMissingLayers = true;
    return this;
  }

  LayerRule build() {
    return LayerRule(
      _layers,
      validationType: _validationType,
      allowMissingLayers: _allowMissingLayers,
    );
  }

  Future<void> check() async {
    await build().check();
  }
}

// Função de conveniência
LayerRuleBuilder layers(List<String> layerNames) {
  return LayerRuleBuilder(layerNames);
}
